#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use tauri::{
	image::Image,
	tray::{TrayIconBuilder, TrayIconEvent},
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

			// Hide on startup — only show when tray icon is clicked
			let _ = window.hide();

			let icon = Image::from_bytes(include_bytes!("../icons/tray.png"))
				.unwrap_or_else(|_| app.default_window_icon().unwrap().clone());

			let win_tray = window.clone();
			TrayIconBuilder::new()
				.icon(icon)
				.icon_as_template(true)
				.on_tray_icon_event(move |tray, event| {
					tauri_plugin_positioner::on_tray_event(tray.app_handle(), &event);
					if let TrayIconEvent::Click { .. } = event {
						if win_tray.is_visible().unwrap_or(false) {
							let _ = win_tray.hide();
						} else {
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
