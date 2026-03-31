#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use std::sync::{Arc, Mutex};
use std::time::{Duration, Instant};
use tauri::{
	image::Image,
	menu::{CheckMenuItem, Menu, MenuItem, Submenu},
	tray::{MouseButton, MouseButtonState, TrayIconBuilder, TrayIconEvent},
	Manager, WindowEvent,
};
use tauri_plugin_positioner::{Position, WindowExt};

fn main() {
	tauri::Builder::default()
		.plugin(tauri_plugin_positioner::init())
		.setup(|app| {
			#[cfg(target_os = "macos")]
			app.set_activation_policy(tauri::ActivationPolicy::Accessory);

			let window = app.get_webview_window("main").unwrap();
			let win_blur = window.clone();

			// Make the webview background fully transparent on macOS
			#[cfg(target_os = "macos")]
			{
				use tauri::WebviewWindowExt;
				window.set_background_color(Some(tauri::Color(0, 0, 0, 0))).ok();
			}

			// Hide on startup — only show when tray icon is clicked
			let _ = window.hide();

			// Track when the window was last shown so the blur handler doesn't
			// immediately close it if focus briefly flickers on open
			let last_shown = Arc::new(Mutex::new(Instant::now() - Duration::from_secs(10)));
			let last_shown_blur = last_shown.clone();
			let last_shown_menu = last_shown.clone();
			let last_shown_tray = last_shown.clone();

			// Hide when clicking outside the panel; reset edit mode
			window.on_window_event(move |event| {
				if let WindowEvent::Focused(false) = event {
					if last_shown_blur.lock().unwrap().elapsed() > Duration::from_millis(300) {
						let _ = win_blur.hide();
						let _ = win_blur.eval("exitEditMode()");
					}
				}
			});

			let icon = Image::from_bytes(include_bytes!("../icons/tray.png"))
				.unwrap_or_else(|_| app.default_window_icon().unwrap().clone());

			// Right-click context menu
			let edit_item   = MenuItem::with_id(app, "edit",         "Edit Symbols",  true, None::<&str>)?;
			// CheckMenuItems so the active theme is visually indicated
			let theme_auto  = CheckMenuItem::with_id(app, "theme_system", "System (Auto)", true, true,  None::<&str>)?;
			let theme_light = CheckMenuItem::with_id(app, "theme_light",  "Light",         true, false, None::<&str>)?;
			let theme_dark  = CheckMenuItem::with_id(app, "theme_dark",   "Dark",          true, false, None::<&str>)?;
			let theme_menu  = Submenu::with_items(app, "Theme", true, &[&theme_auto, &theme_light, &theme_dark])?;
			// Clones for use inside the menu event closure
			let (ta, tl, td) = (theme_auto.clone(), theme_light.clone(), theme_dark.clone());
			let quit_item   = MenuItem::with_id(app, "quit",         "Quit",          true, None::<&str>)?;
			let menu = Menu::with_items(app, &[&edit_item, &theme_menu, &quit_item])?;

			let win_menu = window.clone();
			let win_tray = window.clone();

			TrayIconBuilder::new()
				.icon(icon)
				.icon_as_template(true)
				.menu(&menu)
				.show_menu_on_left_click(false)
				.on_menu_event(move |app, event| {
					match event.id.as_ref() {
						"quit"         => app.exit(0),
						"edit"         => {
							*last_shown_menu.lock().unwrap() = Instant::now();
							let _ = win_menu.move_window(Position::TrayCenter);
							let _ = win_menu.show();
							let _ = win_menu.set_focus();
							let _ = win_menu.eval("enterEditMode()");
						}
						"theme_system" => {
							let _ = ta.set_checked(true);
							let _ = tl.set_checked(false);
							let _ = td.set_checked(false);
							let _ = win_menu.eval("setTheme('system')");
						}
						"theme_light" => {
							let _ = ta.set_checked(false);
							let _ = tl.set_checked(true);
							let _ = td.set_checked(false);
							let _ = win_menu.eval("setTheme('light')");
						}
						"theme_dark" => {
							let _ = ta.set_checked(false);
							let _ = tl.set_checked(false);
							let _ = td.set_checked(true);
							let _ = win_menu.eval("setTheme('dark')");
						}
						_              => {}
					}
				})
				.on_tray_icon_event(move |tray, event| {
					tauri_plugin_positioner::on_tray_event(tray.app_handle(), &event);
					if let TrayIconEvent::Click {
						button: MouseButton::Left,
						button_state: MouseButtonState::Up,
						..
					} = event {
						if win_tray.is_visible().unwrap_or(false) {
							let _ = win_tray.hide();
							let _ = win_tray.eval("exitEditMode()");
						} else {
							*last_shown_tray.lock().unwrap() = Instant::now();
							let _ = win_tray.move_window(Position::TrayCenter);
							let _ = win_tray.show();
							let _ = win_tray.set_focus();
						}
					}
				})
				.build(app)?;

			Ok(())
		})
		.run(tauri::generate_context!())
		.expect("error running SymbolPad");
}