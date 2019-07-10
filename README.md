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
## Successfully sending notification

If the notification is successfully sent, a label on the bottom left side will show with the device name / device token of the device that the notification was sent to .

## Error sending notification

If there is an error while sending a notification, an alert will display giving you the reason. If you get `TooManyRequests` wait a couple minutes before sending another notification to that device as Apple may think that you are spamming that device with too many notifications. 

If you do not get an error alert, and you do not see the label notifying you that the notification was successfully sent, check your payload as it may be in the wrong format. 
