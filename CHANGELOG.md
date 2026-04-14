# Changelog

## [1.0.4] - 14/04/2026

### Changes
- Added more native tools custom UIs
- Performance improvements

## [1.0.3] - 12/02/2026

### Changes
- Added AppBarConfig to show/hide appbar, customize appbar actions and closing icon
- Added DrawerConfig to set a drawer or endDrawer and have access to onDrawerChanged() and onEndDrawerChanged()
- Added `apiUrl` override support for multi-tenant deployments
- Added `PupauConfig.copyWith(...)`
- Added `resetChatOnOpen`parameter in PupauConfig
- Added new `PupauChatUtils` methods: `loadConversation`, `startAnonymousChat`, `toggleAnonymousMode`, `exitAnonymousAndStartNewConversation`, `startNewConversation`, `setNerdStats`, `setHideInputBox`, `reloadCurrentAssistant`, `preloadAssistantsList`, `updateAuthToken`
- Added bearer-token auth refresh flow: emits `authError` on 401 and supports host-driven token update via `PupauChatUtils.updateAuthToken(...)`
- Improved chat performance

## [1.0.2] - 11/02/2026

### Changes
- Added audio recording feature
- Added hideAudioRecordingButton parameter in PupauConfig

## [1.0.1] - 28/01/2026

### Changes
- Improved UI spacing for all widgetMode settings
- Improved support for web
- Improved README

## [1.0.0] - 23/01/2026

### Added
- Initial release of Flutter Agent Pupau plugin