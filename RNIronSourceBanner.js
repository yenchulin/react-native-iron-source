import React from 'react';
import { NativeModules, NativeEventEmitter } from 'react-native';
import { requireNativeComponent } from 'react-native';

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

// const removeAllListeners = () => {
//   supportedEvents.map((eventType) => IronSourceBannerEventEmitter.removeAllListeners(eventType));
// };

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