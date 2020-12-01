import React from 'react';
import { NativeModules, NativeEventEmitter } from 'react-native';
import { requireNativeComponent, ViewPropTypes } from 'react-native';
import { func, string } from 'prop-types';

// const RNIronSourceBanner = NativeModules.RNIronSourceBanner;
// const IronSourceBannerEventEmitter = new NativeEventEmitter(RNIronSourceBanner);

class IronSourceBanner extends React.Component {
  render() {
    return <RNIronSourceBanner {...this.props}/>
  }
}

// const supportedEvents = [
//   'ironSourceBannerDidLoad',
//   'ironSourceBannerDidFailToLoadWithError',
//   'ironSourceBannerDidDismissScreen',
//   'ironSourceBannerWillLeaveApplication',
//   'ironSourceBannerWillPresentScreen',
//   'ironSourceDidClickBanner',
// ]

// const loadBannerDefaultOptions = {
//   position: 'bottom',
//   scaleToFitWidth: false,
// };

// const eventHandlers = supportedEvents.reduce((acc, eventName) => {
//   acc[eventName] = new Map();
//   return acc;
// }, {});

// const addEventListener = (type, handler) => {
//   if (supportedEvents.includes(type)) {
//     eventHandlers[type].set(handler, IronSourceBannerEventEmitter.addListener(type, handler));
//   } else {
//     console.log(`Event with type ${type} does not exist.`);
//   }
// };

// const removeEventListener = (type, handler) => {
//   if (!eventHandlers[type].has(handler)) {
//     return;
//   }
//   eventHandlers[type].get(handler).remove();
//   eventHandlers[type].delete(handler);
// };

IronSourceBanner.propTypes = {
  ...ViewPropTypes,

  /**
   * AdMob iOS library banner size constants
   * (https://developers.google.com/admob/ios/banner)
   * banner (320x50, Standard Banner for Phones and Tablets)
   * largeBanner (320x100, Large Banner for Phones and Tablets)
   * mediumRectangle (300x250, IAB Medium Rectangle for Phones and Tablets)
   * fullBanner (468x60, IAB Full-Size Banner for Tablets)
   * leaderboard (728x90, IAB Leaderboard for Tablets)
   * smartBannerPortrait (Screen width x 32|50|90, Smart Banner for Phones and Tablets)
   * smartBannerLandscape (Screen width x 32|50|90, Smart Banner for Phones and Tablets)
   *
   * banner is default
   */
  adSize: string,
  // onSizeChange: func,
  onAdLoaded: func,
  onAdFailedToLoad: func,
  onAdOpened: func,
  onAdClosed: func,
  onAdLeftApplication: func,
  onAdClick: func,
};

// module.exports = {
//   ...RNIronSourceBanner,
//   initializeBanner: () => {}, // Deprecated. Here for backwards compatibility with 2.5.3
//   loadBanner: (size = 'BANNER', options) => RNIronSourceBanner.loadBanner(size, {
//     ...loadBannerDefaultOptions,
//     ...options,
//   }),
//   showBanner: () => RNIronSourceBanner.showBanner(),
//   hideBanner: () => RNIronSourceBanner.hideBanner(),
//   destroyBanner: () => RNIronSourceBanner.destroyBanner(),
//   addEventListener,
//   removeEventListener,
//   removeAllListeners
// };

const RNIronSourceBanner = requireNativeComponent('RNIronSourceBanner', IronSourceBanner);
// module.exports = RNIronSourceBanner;
export default IronSourceBanner;