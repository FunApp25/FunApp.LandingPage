/// No-op implementation for non-web test environments.
void launchPrivacyNoticeLinkImpl(Uri uri) {}

/// No-op contact-link implementation for non-web test environments.
void launchContactLinkImpl(Uri uri) {}

/// No-op implementation for non-web test environments.
void launchExternalLinkInNewTabImpl(Uri uri) {}

/// No browser default navigation exists outside the web renderer.
void Function() installLegalLinkNavigationImpl(String identifier) => () {};
