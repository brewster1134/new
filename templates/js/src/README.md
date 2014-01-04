#### CHANGE LOG
###### 0.0.1
* Initial Alpha

###### 0.0.3
* Initial Refactor

###### 0.0.4
* renamed `checkConnectionDelay` to `retryInterval`
* removed `checkConnectionUrl` and `isConnected` method
* `start` now processing queue immediately and then sets interval
* using `setInterval` instead of `setTimeout`
