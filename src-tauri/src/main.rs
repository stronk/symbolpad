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
            let win_blur = window.clone();
            window.on_window_event(move |event| {
                if let WindowEvent::Focused(false) = event {
                    let _ = win_blur.hide();
                }
            });

            let icon = Image::from_path("icons/tray.png")
                .unwrap_or_else(|_| app.default_window_icon().unwrap().clone());

            let win_tray = window.clone();
            TrayIconBuilder::new()
                .icon(icon)
                .icon_as_template(true)
                .on_tray_icon_event(move |_tray, event| {
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
