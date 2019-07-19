## Preparing to a send notification

* Add the Bundle Identifier for the app you want to send the notification to by selecting **`Add BundleId`** button and enter the Bundle Identifier you want. Alternatively, you can import a **.csv** file in the following format `Project Name` `BundleId`.

* Add the contact/device token of the device you want to send the notification to. You can also import a **.csv** file in `Device Name` `Contact` format.

* Select your private key with a  **.p8** extension associated with your developer account.

* Enter your **`Team ID`** that is associated with the project you are sending the notification to. 

* Enter your  **`Key ID`** that is associated with the private key you chose.

* Choose whether you want to send the notification on Apple's sandbox or production environment. Sandbox is chosen by default.

* Enter the payload you want to send in the notification. Payload needs to be in the following base format in order to send the notification:
```
{
 "aps": {
   "alert": "Message to be sent"
  }
}
```

Additionally, you can add onto the payload to send additional information to the device:
```
{
 “aps”: {
   “alert”: {
     “title”: “Game Request”,
     “subtitle”: “Five Card Draw”,
     “body”: “Bob wants to play poker”,

   },
   “category”: “GAME_INVITATION”
  },
  “gameID”: “12345678”,
  “messageID” : “ABCDEFGHIJ”
}
```
## Successfully sending a notification

If the notification is successfully sent, a label on the bottom left side will show with the device name / device token of the device that the notification was sent to .

## Error sending a notification

If there is an error while sending a notification, an alert will display giving you the reason. If you get `TooManyRequests` wait a couple minutes before sending another notification to that device as Apple may think that you are spamming that device with too many notifications. 

If you do not get an error alert, and you do not see the label notifying you that the notification was successfully sent, check your payload as it may be in the wrong format. 

The table below are examples of errors that may be received from APNs.

| Status Code | Error String | Description |
|--|--|--|
| 400 | BadCollapseId | The collapse identifier exceeds the maximum allowed size. |
| 400 | BadDeviceToken | The specified device token was bad. Verify that the request contains a valid token and that the token matches the environment. |
| 400 | BadExpirationDate | The `apns-expiration` value is bad. |
| 400 | BadMessageId | The `apns-id` value is bad. |
| 400 | BadPriority | The `apns-priority` value is bad. |
| 400 | BadTopic | The `apns-topic` was invalid. |
| 400 | DeviceTokenNotForTopic | The device token does not match the specified topic. |
| 400 | DuplicateHeaders | One or more headers were repeated. |
| 400 | IdleTimeout | Idle time out. |
| 400 | MissingDeviceToken | The device token is not specified in the request `:path`. Verify that the `:path` header contains the device token. |
| 400 | MissingTopic | The `apns-topic` header of the request was not specified and was required. The apns-topic header is mandatory when the client is connected using a certificate that supports multiple topics. |
| 400 | PayloadEmpty | The message payload was empty. |
| 400 | TopicDisallowed | Pushing to this topic is not allowed. |
| 403 | BadCertificate | The certificate was bad. |
| 403 | BadCertificateEnvironment | The client certificate was for the wrong environment. |
| 403 | ExpiredProviderToken | The provider token is stale and a new token should be generated. |
| 403 | Forbidden | The specified action is not allowed. |
| 403 | InvalidProviderToken | The provider token is not valid or the token signature could not be verified. |
| 403 | MissingProviderToken | No provider certificate was used to connect to APNs and Authorization header was missing or no provider token was specified. |
| 404 | BadPath | The request contained a bad `:path` value. |
| 405 | MethodNotAllowed | The specified `:method` was not `POST`. |
| 410 | Unregistered | The device token is inactive for the specified topic. |
| 413 | PayloadTooLarge | The message payload was too large. See [Creating the Remote Notification Payload](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CreatingtheNotificationPayload.html#//apple_ref/doc/uid/TP40008194-CH10-SW1) for details on maximum payload size. |
| 429 | TooManyProviderTokenUpdates | Too many requests were made consecutively to the same device token. |
| 429 | TooManyRequests | The collapse identifier exceeds the maximum allowed size. |
| 500 | InternalServerError | An internal server error occurred. |
| 503 | ServiceUnavailable | The service is unavailable. |
| 503 | Shutdown | The server is shutting down. |
