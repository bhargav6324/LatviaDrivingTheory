/**
 * Latvia Driving Theory - Centralized Application Configuration
 * All key URLs, support emails, and metadata are maintained here for easy updates.
 */
const APP_CONFIG = {
  appName: "CSDD Teorijas Eksāmens",
  appNameEn: "Latvia Driving Theory Test",
  appCategory: "Category B Driving Theory Preparation",
  
  // App Store URL:
  // Replace '#' with your live App Store URL once your app is approved in App Store Connect.
  appStoreUrl: "#",
  isAppStoreLive: false,

  // Support Contact Email:
  supportEmail: "raxitsingh2002@gmail.com",

  // Supported Languages (Latvian primary default, English secondary)
  defaultLanguage: "lv",
  supportedLanguages: ["lv", "en"],

  // Legal & Meta
  lastUpdated: "October 2026",
  copyrightYear: 2026,
  developer: "Latvia Driving Theory",
  
  // Pricing display
  pricing: {
    monthly: "€6.99",
    lifetime: "€9.99"
  }
};

// Export for module or browser window
if (typeof window !== "undefined") {
  window.APP_CONFIG = APP_CONFIG;
}
if (typeof module !== "undefined" && module.exports) {
  module.exports = APP_CONFIG;
}
