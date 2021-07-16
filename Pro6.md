# ProPresenter-API
Documenting RenewedVision's undocumented network protocols with examples

This document refers to *ProPresenter 6*.

Both the Remote Control and the Stage Display protocols are unencrypted text-based websocket connections from the client to the ProPresenter instance.

Note, if both the Remote Control and the Stage Display interface are enabled in ProPresenter, they both operate over the *Remote Control* network port.

## Remote Control


### Connecting

```javascript
ws://[host]:[port]/remote
```

### Authenticate

COMMAND TO SEND:

```javascript
{"action":"authenticate","protocol":"600","password":"control"}
```
* protocol is used to perform a version check. ProPresenter 6 seems to check for a value here of at least 600 - otherwise it denies authentication and returns "Protocol out of date. Update application"

EXPECTED RESPONSE:

```javascript
{"controller":1,"authenticated":1,"error":"","action":"authenticate"}
```

### Get Library (all presentations)

COMMAND TO SEND:

```javascript
{"action":"libraryRequest"}
```

EXPECTED RESPONSE:

```javascript
{
  "library": [
    "\/Path\/To\/ProPresenter\/Library\/Come Alive (Dry Bones).pro6",
    "\/Path\/To\/ProPresenter\/Library\/Pour Out My Heart.pro6",
    "\/Path\/To\/ProPresenter\/Library\/Away in a manger.pro6",
	"... ALL PRESENTATIONS IN THE LIBRARY ..."
  ],
  "action": "libraryRequest"
}
```

* Note the use of slashes in the response. ProPresenter expects library requests to follow this pattern exactly.

### Get All Playlists

COMMAND TO SEND:

```javascript
{"action":"playlistRequestAll"}
```

EXPECTED RESPONSE:

This request returns all playlists according to the following format.

```javascript
{
  "playlistAll": [
    {
      "playlistLocation": "0",
      "playlistType": "playlistTypePlaylist",
      "playlistName": "Default",
      "playlist": [
        {
          "playlistItemName": "!~ PRE-SERVICE",
          "playlistItemLocation": "0:0",
          "playlistItemType": "playlistItemTypePresentation"
        },
      ]
    },
    {
      "playlistLocation": "1",
      "playlistType": "playlistTypeGroup",
      "playlistName": "2017",
      "playlist": [
        {
          "playlistLocation": "1.0",
          "playlistType": "playlistTypePlaylist",
          "playlistName": "2017-01-28-Vision Dinner",
          "playlist": [
            {
              "playlistItemName": "!MISC2",
              "playlistItemLocation": "1.0:0",
              "playlistItemType": "playlistItemTypePresentation"
            },
            {
              "playlistItemName": "!MISC1",
              "playlistItemLocation": "1.0:1",
              "playlistItemType": "playlistItemTypePresentation"
            },
          ]
        },
      ]
    }
  ],
  "action": "playlistRequestAll"
}
```

### Request Presentation (set of slides)

COMMAND TO SEND:

```javascript
{
    "action": "presentationRequest",
    "presentationPath": "\/Path\/To\/ProPresenter\/Library\/Song 1 Title.pro6",
    "presentationSlideQuality": 25
}
```

* `presentationPath` is required and it can be structured in one of three ways
  * It can be a full path to a pro6 file but note that all slashes need to be preceeded by a backslash in the request.
  * It can be the basename of a presentation that exists in the library (eg. `Song 1 Title.pro6`) is (sometimes?) good enough.
  * It can be the "playlist location" of the presentation. The playlist location is determined according to the order of items in the playlist window, the items are indexed from 0, and groups are sub-indexed with a dot, then presentations inside the playlist are indexed with a colon and a numeral. That is, the first presentation of the first playlist is `0:0` and if the first playlist item is a group, the first item of the first playlist of that group is `0.0:0`
  * A presentationPath specified with a playlist address and not a filename seems to be the most reliable.
* `presentationSlideQuality` is optional. It determines the resolution / size of the slide previews sent from ProPresenter. If left blank, high quality previews will be sent. If set to `0` previews will not be generated at all. The remote app asks for quality `25` first and then follows it up with a second request for quality `100`.

EXPECTED RESPONSE:

```javascript
{
    "action": "presentationCurrent",
    "presentation": {
        "presentationSlideGroups": [
            {
                "groupName": "[SLIDE GROUP NAME]",
                "groupColor": "0 0 0 1", // RGBA scale is from 0-1
                "groupSlides": [
                    {
                        "slideEnabled": true,
                        "slideNotes": "",
                        "slideAttachmentMask": 0,
                        "slideText": "[SLIDE TEXT HERE]",
                        "slideImage": "[BASE64 ENCODED IMAGE]",
                        "slideIndex": "0",
                        "slideTransitionType": -1,
                        "slideLabel": "[SLIDE LABEL]",
                        "slideColor": "0 0 0 1"
                    }
                ]
            },
        ],
        "presentationName": "[PRESENTATION TITLE]",
        "presentationHasTimeline": 0,
        "presentationCurrentLocation": "[PRESENTATION PATH OF CURRENTLY ACTIVE SLIDE]"
    }
}
```

* The response contains `presentationCurrent` as the action instead of `presentationRequest`. This seems to be a bug in the ProPresenter response.
* The `presentationCurrentLocation` is not the location of the presentation you requested. It is the path of the presentation whose slide is currently active.
* You can distinguish this response from the real `presentationCurrent` request because that response will include `presentationPath` as a field at the root level of the response.

### Request Current Presentation

COMMAND TO SEND:

```javascript
{ "action":"presentationCurrent", "presentationSlideQuality": 25}
```

EXPECTED RESPONSE:

Same response as `requestPresentation` except this response will include `presentationPath` as a field at the root level of the response.

* NOTE: This action only seems to work if there is an *active slide*. When ProPresenter starts, no slide is marked active, so this action *returns nothing until a slide has been triggered*.


### Get Index of Current Slide

COMMAND TO SEND:

```javascript
{"action":"presentationSlideIndex"}
```
EXPECTED RESPONSE:

```javascript
{"action":"presentationSlideIndex","slideIndex":"0"}
```

* NOTE: The ProPresenter remote issues this action every time it issues a `presentationRequest` action.

### Trigger Slide

COMMAND TO SEND:

```javascript
{"action":"presentationTriggerIndex","slideIndex":3,"presentationPath":"[PRESENTATION PATH]"}
```

EXPECTED RESPONSE:

```javascript
{"slideIndex":3,"action":"presentationTriggerIndex","presentationPath":"[PRESENTATION PATH]"}
```

### Trigger Next Slide

COMMAND TO SEND:

```javascript
{"action":"presentationTriggerNext"}
```

EXPECTED RESPONSE:

```javascript
{"slideIndex":3,"action":"presentationTriggerIndex","presentationPath":"[PRESENTATION PATH]"}
```

### Trigger Previous Slide

COMMAND TO SEND:

```javascript
{"action":"presentationTriggerPrevious"}
```

EXPECTED RESPONSE:

```javascript
{"slideIndex":3,"action":"presentationTriggerIndex","presentationPath":"[PRESENTATION PATH]"}
```

### Get Audio Library

COMMAND TO SEND:

```javascript
{ "action": "audioRequest" }
```

EXPECTED RESPONSE:

```javascript
{
  "action": "audioRequest",
  "audioPlaylist": [
    {
      "playlistLocation": "0",
      "playlistType": "playlistTypePlaylist",
      "playlistName": "Library",
      "playlist": [
        {
          "playlistItemName": "1-11 Have Yourself A Merry Little Christmas.mp3",
          "playlistItemArtist": "Chinua Hawk",
          "playlistItemType": "playlistItemTypeAudio",
          "playlistItemLocation": "0:0"
        }
      ]
    },
    {
      "playlistLocation": "1",
      "playlistType": "playlistTypeGroup",
      "playlistName": "Service End",
      "playlist": [
        {
          "playlistLocation": "1.0",
          "playlistType": "playlistTypePlaylist",
          "playlistName": "random",
          "playlist": [
            {
              "playlistItemName": "03 Black Coal.mp3",
              "playlistItemArtist": "Sanctus Real",
              "playlistItemType": "playlistItemTypeAudio",
              "playlistItemLocation": "1.0:0"
            }
          ]
        }
      ]
    },
    {
      "playlistLocation": "2",
      "playlistType": "playlistTypeGroup",
      "playlistName": "Christmas",
      "playlist": []
    }
  ]
}
```

### Get Current Song

COMMAND TO SEND:

```javascript
{ "action": "audioCurrentSong" }
```

EXPECTED RESPONSE:

```javascript
{
  "audioArtist": "",
  "action": "audioCurrentSong",
  "audioName": "Peaceful Instrumental - C"
}
```

### Check if Audio is Playing (BROKEN)

ProPresenter 6 always replies "false" to this request.

COMMAND TO SEND:

```javascript
{ "action": "audioIsPlaying" }
```

EXPECTED RESPONSE:

```javascript
{"audioIsPlaying":false,"action":"audioIsPlaying"}
```

### Start Audio Cue

COMMAND TO SEND:

```javascript
{"action":"audioStartCue", "audioChildPath","[Same as Presentation Path Format]"}
```

EXPECTED RESPONSE:

There are multiple responses for an audio cue trigger.

```javascript
{"action":"audioPlayPause","audioPlayPause":"Play"}
```

```javascript
{
  "audioArtist": "",
  "action": "audioTriggered",
  "audioName": "Peaceful Instrumental - C"
}
```

### Audio Play/Pause Toggle

COMMAND TO SEND:

```javascript
{"action":"audioPlayPause"}
```

### TimeLine Play/Pause Toggle

COMMAND TO SEND:

```javascript
{"action":"timelinePlayPause","presentationPath":"[PRESENTATION PATH]"}
```

### TimeLine Rewind

COMMAND TO SEND:

```javascript
{"action":"timelineRewind":,"presentationPath":"[PRESENTATION PATH]"}
```

### Get Clock (Timers) Info

COMMAND TO SEND:

```javascript
{"action":"clockRequest"}
```
### Start Receiving Updates for Clocks (Timers)

COMMAND TO SEND:

```javascript
{"action":"clockStartSendingCurrentTime"}
```

### Stop Receiving Updates for Clocks (Timers)

COMMAND TO SEND:

```javascript
{"action":"clockStopSendingCurrentTime"}
```

### Request all Clocks

COMMAND TO SEND:

```javascript
{"action":"clockRequest"}
```

EXPECTED RESPONSE:

```javascript
{
  "clockInfo": [
    {
      "clockType": 0,
      "clockState": false,
      "clockName": "Countdown 1",
      "clockIsPM": 0,
      "clockDuration": "0:10:00",
      "clockOverrun": false,
      "clockEndTime": "--:--:--",
      "clockTime": "--:--:--"
    },
    {
      "clockType": 1,
      "clockState": false,
      "clockName": "Countdown 2",
      "clockIsPM": 1,
      "clockDuration": "7:00:00",
      "clockOverrun": false,
      "clockEndTime": "--:--:--",
      "clockTime": "--:--:--"
    },
    {
      "clockType": 2,
      "clockState": false,
      "clockName": "Elapsed Time",
      "clockIsPM": 0,
      "clockDuration": "0:00:00",
      "clockOverrun": false,
      "clockEndTime": "--:--:--",
      "clockTime": "13:52:23"
    }
  ],
  "action": "clockRequest"
}
```

### Get Clock Current Times

COMMAND TO SEND:

```javascript
{"action":"clockCurrentTimes"}
```

EXPECTED RESPONSE:

```javascript
{"action":"clockCurrentTimes","clockTimes":["0:10:00","--:--:--","13:52:23"]}
```

### Start a Clock (Timer)

COMMAND TO SEND:

```javascript
{"action":"clockStart","clockIndex":"0"}
```

EXPECTED RESPONSE:

```javascript
{"clockTime":"0:00:00","clockState":1,"clockIndex":0,"clockInfo":[1,1,"0:00:00"],"action":"clockStartStop"}
```
* `clockState` indicates if the clock is running or not
* Clocks are referenced by index. See reply from "clockRequest" action above to learn indices.

### Stop a Clock (Timer)

COMMAND TO SEND:

```javascript
{"action":"clockStop","clockIndex":"0"}
```

EXPECTED RESPONSE:

```javascript
{"clockTime":"0:00:00","clockState":0,"clockIndex":0,"clockInfo":[1,1,"0:00:00"],"action":"clockStartStop"}
```

* `clockState` indicates if the clock is running or not
* Clocks are referenced by index. See reply from "clockRequest" action above to learn indices.

### Reset a Clock (Timer)

COMMAND TO SEND:

```javascript
{"action":"clockReset","clockIndex":"0"}
```
* Clocks are referenced by index. See reply from "clockRequest" action above to learn indices.

### Update a Clock (Timer) (eg edit time)

COMMAND TO SEND:

```javascript
{
  "action":"clockUpdate",
  "clockIndex":"1",
  "clockType":"0",
  "clockTime":"09:04:00",
  "clockOverrun":"false",
  "clockIsPM":"1",
  "clockName":"Countdown 2",
  "clockElapsedTime":"0:02:00"
}
```

* Clocks are referenced by index. See reply from "clockRequest" action above to learn indexes.
* Not all parameters are required for each clock type.
  * Countdown clocks only need "clockTime".
  * Elapsed Time Clocks need "clockTime" and optionally will use "clockElapsedTime" if you send it (to set the End Time).
  * You can rename a clock by optionally including the clockName.
  * Type 0 is Countdown
  * Type 1 is CountDown to Time
  * Type 2 is Elapsed Time.
  * Overrun can be modified if you choose to include that as well.

### Start Getting Clock Updates

COMMAND TO SEND:

```javascript
{"action":"clockStartSendingCurrentTime"}
```

EXPECTED RESPONSE (every second):

```javascript
{"action":"clockCurrentTimes","clockTimes":["0:10:00","--:--:--","13:52:23"]}
```

### Additional Clock Actions

`clockResetAll`, `clockStopAll`, `clockStartAll`


### Get all Messages

COMMAND TO SEND:

```javascript
{"action":"messageRequest"}
```

EXPECTED RESPONSE:

```javascript
{
  "action": "messageRequest",
  "messages": [
    {
      "messageComponents": [
        "message:",
        "${Message}"
      ],
      "messageTitle": "Message"
    },
    {
      "messageComponents": [
        "Session will begin in: ",
        "${Countdown 1: H:MM:SS}"
      ],
      "messageTitle": "Countdown"
    },
    {
      "messageComponents": [
        "${Message}"
      ],
      "messageTitle": "Message"
    },
    {
      "messageComponents": [
        "Service starts in ",
        "${countDownTimerName_1: H:MM:SS}"
      ],
      "messageTitle": "Countdown"
    }
  ]
}
```

* The key is everything inside the curly braces `${}` so that the key for a countdown looks like this `Countdown 1: H:MM:SS`.
* If the key refers to a countdown, the value is used to update the `duration` field of the countdown timer, but will not perform a "reset".
* If the key refers to a countdown and the countdown is not running, this will resume it from its current value.

### Display a Message

Display a message identified by its index. Add as many key, value pairs as you like. Keys can be name of timers.

COMMAND TO SEND:

```javascript
{"action":"messageSend","messageIndex":0,"messageKeys":"["key1","key2"....]","messageValues":"["Value1","Value2"...]"}
```

AN EXAMPLE USING THE DATA ABOVE:

```javascript
{"action":"messageSend","messageIndex":0,"messageKeys":["Message"],"messageValues":["Test"]}
```

### Hide a Message

COMMAND TO SEND:
Hide a message identified by its index

```javascript
{"action":"messageHide","messageIndex","0"}
```

### Clear All

COMMAND TO SEND:

```javascript
{"action":"clearAll"}
```

### Clear Slide

COMMAND TO SEND:

```javascript
{"action":"clearText"}
```

### Clear Props

COMMAND TO SEND:

```javascript
{"action":"clearProps"}
```

### Clear Audio

COMMAND TO SEND:

```javascript
{"action":"clearAudio"}
```

### Clear Video

COMMAND TO SEND:

```javascript
{"action":"clearVideo"}
```

### Clear Telestrator

COMMAND TO SEND:

```javascript
{"action":"clearTelestrator"}
```

### Clear To Logo

COMMAND TO SEND:

```javascript
{"action":"clearToLogo"}
```

### Show Stage Display Message

COMMAND TO SEND:

```javascript
{"action":"stageDisplaySendMessage","stageDisplayMessage":"Type a Message Here"}
```

THERE IS NO EXPECTED RESPONSE

### Hide Stage Display Message

COMMAND TO SEND:

```javascript
{"action":"stageDisplayHideMessage"}
```

THERE IS NO EXPECTED RESPONSE

### Select Stage Display Layout

COMMAND TO SEND:

```javascript
{"action":"stageDisplaySetIndex","stageDisplayIndex":"[STAGE DISPLAY INDEX]"}
```

EXPECTED RESPONSE IS THE SAME AS THE SENT COMMAND

### Get Stage Display Layouts

COMMAND TO SEND:

```javascript
{ "action": "stageDisplaySets" }
```

EXPECTED RESPONSE:

```javascript
{
  "stageDisplayIndex": 4,
  "action": "stageDisplaySets",
  "stageDisplaySets": [
    "Default",
    "Easter Closer",
    "Live Current - Static Next - no borders",
    "Static Current - Static Next",
    "Songs",
    "Slides"
  ]
}
```

## TODO: Complete documentation for remaining remote commands... 
socialSendTweet
telestratorSettings
telestratorEndEditing
telestratorSet
telestratorUndo
telestratorNew

## Stage Display API

### Connecting

```javascript
ws://[host]:[port]/stagedisplay
```

### Authenticate

COMMAND TO SEND:

```javascript
{"pwd":PASSWORD,"ptl":610,"acn":"ath"}
```

EXPECTED RESPONSE:

```javascript
{"acn":"ath","ath":true,"err":""}
```

### Get All Stage Display Layouts

COMMAND TO SEND:

```javascript
{"acn":"asl"}
```

EXPECTED RESPONSE:

```javascript
{
  "acn": "asl",
  "ary": [
    {
      "brd": true,
      "uid": "753B184F-CCCD-42F9-A883-D1DF86E1FFB8",
      "zro": 0,
      "oCl": "1.000000 0.000000 0.000000",
      "fme": [
        {
          "ufr": "{{0.025000000000000001, 0.37418655097613884}, {0.40000000000000002, 0.50108459869848154}}",
          "mde": 1,
          "tCl": "1.000000 1.000000 1.000000",
          "tAl": 2,
          "tSz": 60,
          "nme": "Current Slide",
          "typ": 1
        },
        {
          "ufr": "{{0.024390243902439025, 0.27223427331887201}, {0.40182926829268295, 0.10412147505422993}}",
          "mde": 1,
          "tCl": "1.000000 1.000000 1.000000",
          "tAl": 2,
          "tSz": 60,
          "nme": "Current Slide Notes",
          "typ": 3
        },
        {
          "ufr": "{{0.45000000000000001, 0.47396963123644253}, {0.29999999999999999, 0.40021691973969631}}",
          "mde": 1,
          "tCl": "1.000000 1.000000 1.000000",
          "tAl": 2,
          "tSz": 60,
          "nme": "Next Slide",
          "typ": 2
        },
        {
          "ufr": "{{0.45000000000000001, 0.37310195227765725}, {0.29999999999999999, 0.1019522776572668}}",
          "mde": 1,
          "tCl": "1.000000 1.000000 1.000000",
          "tAl": 2,
          "tSz": 60,
          "nme": "Next Slide Notes",
          "typ": 4
        },
        {
          "ufr": "{{0.77500000000000002, 0.37418655097613884}, {0.20000000000000001, 0.40130151843817785}}",
          "nme": "Chord Chart",
          "mde": 1,
          "typ": 9
        },
        {
          "ufr": "{{0.050000000000000003, 0.89913232104121477}, {0.20000000000000001, 0.1019522776572668}}",
          "mde": 1,
          "tCl": "1.000000 1.000000 1.000000",
          "tAl": 2,
          "tSz": 200,
          "nme": "Clock",
          "typ": 6
        },
        {
          "ufr": "{{0.40000000000000002, 0.89913232104121477}, {0.20000000000000001, 0.1019522776572668}}",
          "mde": 1,
          "tCl": "1.000000 1.000000 1.000000",
          "tAl": 2,
          "tSz": 200,
          "nme": "Video Countdown",
          "typ": 8
        },
        {
          "ufr": "{{0.050000000000000003, 0.024945770065075923}, {0.90000000000000002, 0.10086767895878525}}",
          "fCl": "0.000000 1.000000 0.000000",
          "mde": 1,
          "tCl": "1.000000 1.000000 1.000000",
          "tAl": 2,
          "fCh": true,
          "tSz": 60,
          "nme": "Message",
          "typ": 5
        },
        {
          "ufr": "{{0.68978420350609759, 0.89488713394793928}, {0.20000000000000001, 0.1019522776572668}}",
          "uid": "47E8B48C-0D61-4EFC-9517-BF9FB894C8E2",
          "mde": 1,
          "tCl": "1.000000 1.000000 1.000000",
          "tAl": 2,
          "tSz": 200,
          "nme": "Countdown 1",
          "typ": 7
        }
      ],
      "ovr": true,
      "acn": "sl",
      "nme": "Default"
    },
    {
      "brd": false,
      "uid": "50AF3434-4328-40AC-846F-CC9583381311",
      "zro": 0,
      "oCl": "0.985948 0.000000 0.026951",
      "fme": [
        {
          "ufr": "{{0.60304878048780486, 0.1963123644251627}, {0.39695121951219514, 0.80043383947939262}}",
          "mde": 1,
          "tCl": "0.990463 1.000000 0.041173",
          "tAl": 1,
          "tSz": 80,
          "nme": "Current Slide",
          "typ": 1
        },
        {
          "ufr": "{{0.0024390243902439024, 0.0021691973969631237}, {0.599390243902439, 0.99457700650759218}}",
          "mde": 1,
          "tCl": "0.679783 1.000000 0.885215",
          "tAl": 0,
          "tSz": 120,
          "nme": "Current Slide Notes",
          "typ": 3
        },
        {
          "ufr": "{{0.60304878048780486, 0.0021691973969631237}, {0.39512195121951221, 0.19305856832971802}}",
          "uid": "D1096B85-CF31-4365-A6E6-ED94264E7DCA",
          "mde": 1,
          "tCl": "1.000000 1.000000 1.000000",
          "tAl": 2,
          "tSz": 200,
          "nme": "Elapsed Time",
          "typ": 7
        }
      ],
      "ovr": false,
      "acn": "sl",
      "nme": "Easter Closer"
    },
    {
      "brd": false,
      "uid": "F8260B13-9C5B-4D2C-80F1-C72346759F11",
      "zro": 0,
      "oCl": "0.985948 0.000000 0.026951",
      "fme": [
        {
          "ufr": "{{0.025000000000000001, 0.37418655097613884}, {0.40000000000000002, 0.50108459869848154}}",
          "mde": 2,
          "tCl": "1.000000 1.000000 1.000000",
          "tAl": 2,
          "tSz": 60,
          "nme": "Current Slide",
          "typ": 1
        },
        {
          "ufr": "{{0.025000000000000001, 0.27440347071583515}, {0.40000000000000002, 0.10086767895878525}}",
          "mde": 1,
          "tCl": "1.000000 1.000000 1.000000",
          "tAl": 2,
          "tSz": 60,
          "nme": "Current Slide Notes",
          "typ": 3
        },
        {
          "ufr": "{{0.45000000000000001, 0.47396963123644253}, {0.29999999999999999, 0.40021691973969631}}",
          "mde": 0,
          "tCl": "1.000000 1.000000 1.000000",
          "tAl": 2,
          "tSz": 60,
          "nme": "Next Slide",
          "typ": 2
        },
        {
          "ufr": "{{0.45000000000000001, 0.37310195227765725}, {0.29999999999999999, 0.1019522776572668}}",
          "mde": 1,
          "tCl": "1.000000 1.000000 1.000000",
          "tAl": 2,
          "tSz": 60,
          "nme": "Next Slide Notes",
          "typ": 4
        },
        {
          "ufr": "{{0.77500000000000002, 0.37418655097613884}, {0.20000000000000001, 0.40130151843817785}}",
          "nme": "Chord Chart",
          "mde": 1,
          "typ": 9
        },
        {
          "ufr": "{{0, 0.89804772234273322}, {0.20060975609756099, 0.10303687635574837}}",
          "mde": 1,
          "tCl": "1.000000 1.000000 1.000000",
          "tAl": 2,
          "tSz": 200,
          "nme": "Clock",
          "typ": 6
        },
        {
          "ufr": "{{0.79878048780487809, 0.89696312364425168}, {0.20060975609756099, 0.10303687635574837}}",
          "mde": 1,
          "tCl": "1.000000 1.000000 1.000000",
          "tAl": 2,
          "tSz": 200,
          "nme": "Video Countdown",
          "typ": 8
        },
        {
          "ufr": "{{0.050000000000000003, 0.024945770065075923}, {0.90000000000000002, 0.10086767895878525}}",
          "fCl": "0.135296 1.000000 0.024919",
          "mde": 1,
          "tCl": "1.000000 1.000000 1.000000",
          "tAl": 2,
          "fCh": true,
          "tSz": 60,
          "nme": "Message",
          "typ": 5
        }
      ],
      "ovr": false,
      "acn": "sl",
      "nme": "Live Current - Static Next - no borders"
    },
    {
      "brd": true,
      "uid": "12CB7383-FA02-47BB-B501-747ADCA860D3",
      "zro": 0,
      "oCl": "0.985948 0.000000 0.026951",
      "fme": [
        {
          "ufr": "{{0.025000000000000001, 0.37418655097613884}, {0.40000000000000002, 0.50108459869848154}}",
          "mde": 0,
          "tCl": "1.000000 1.000000 1.000000",
          "tAl": 2,
          "tSz": 60,
          "nme": "Current Slide",
          "typ": 1
        },
        {
          "ufr": "{{0.025000000000000001, 0.27440347071583515}, {0.40000000000000002, 0.10086767895878525}}",
          "mde": 1,
          "tCl": "1.000000 1.000000 1.000000",
          "tAl": 2,
          "tSz": 60,
          "nme": "Current Slide Notes",
          "typ": 3
        },
        {
          "ufr": "{{0.45000000000000001, 0.47396963123644253}, {0.29999999999999999, 0.40021691973969631}}",
          "mde": 0,
          "tCl": "1.000000 1.000000 1.000000",
          "tAl": 2,
          "tSz": 60,
          "nme": "Next Slide",
          "typ": 2
        },
        {
          "ufr": "{{0.45000000000000001, 0.37310195227765725}, {0.29999999999999999, 0.1019522776572668}}",
          "mde": 1,
          "tCl": "1.000000 1.000000 1.000000",
          "tAl": 2,
          "tSz": 60,
          "nme": "Next Slide Notes",
          "typ": 4
        },
        {
          "ufr": "{{0.77500000000000002, 0.37418655097613884}, {0.20000000000000001, 0.40130151843817785}}",
          "nme": "Chord Chart",
          "mde": 1,
          "typ": 9
        },
        {
          "ufr": "{{0, 0.89804772234273322}, {0.20060975609756099, 0.10303687635574837}}",
          "mde": 1,
          "tCl": "1.000000 1.000000 1.000000",
          "tAl": 2,
          "tSz": 200,
          "nme": "Clock",
          "typ": 6
        },
        {
          "ufr": "{{0.79878048780487809, 0.89696312364425168}, {0.20060975609756099, 0.10303687635574837}}",
          "mde": 1,
          "tCl": "1.000000 1.000000 1.000000",
          "tAl": 2,
          "tSz": 200,
          "nme": "Video Countdown",
          "typ": 8
        },
        {
          "ufr": "{{0.050000000000000003, 0.024945770065075923}, {0.90000000000000002, 0.10086767895878525}}",
          "fCl": "0.135296 1.000000 0.024919",
          "mde": 1,
          "tCl": "1.000000 1.000000 1.000000",
          "tAl": 2,
          "fCh": true,
          "tSz": 60,
          "nme": "Message",
          "typ": 5
        }
      ],
      "ovr": false,
      "acn": "sl",
      "nme": "Static Current - Static Next"
    }
  ]
}
```

* `acn` of `asl` means "all stage layouts"
* `ary` indicates array of stage layouts
* `nme` indicates layout name
* `ovr` indicates if overrun color should be used
* `oCl` indicates color for timer overruns
* `brd` indicates if borders and labels should be used
* `uid` indicates layout uid
* `zro` indicates if zeroes should be removed from times
* `fme` indicates array of frame layout specifications
* frame positions are indicated by `ufr` and specified in terms of screen percentages
* frame name is indicated by `nme`
* frame text color is indicated by `tCl`
* frame font size is indicated by `tSz`
* frame message flash color is indicated by `fCl`
* frame use message flash indicated by `fCh`
* frame timer uid is indicated by `uid`
* frame mode is indicated by `mde`
  * mode 0: static image
  * mode 1: text
  * mode 2: live slide
* frame type is indicated by `typ` and determines what content goes in this frame
  * type 1: current slide
  * type 2: next slide
  * type 3: current slide notes
  * type 4: next slide notes
  * type 5: Stage Message (uses message flash values)
  * type 6: Clock
  * type 7: Timer Display (uses `uid` to specify timer)
  * type 8: Video Countdown
  * type 9: Chord Chart

### On New Stage Display Selected

```javascript
{
  "brd": true,
  "uid": "12CB7383-FA02-47BB-B501-747ADCA860D3",
  "zro": 0,
  "oCl": "0.985948 0.000000 0.026951",
  "fme": [
    {
      "ufr": "{{0.025000000000000001, 0.37418655097613884}, {0.40000000000000002, 0.50108459869848154}}",
      "mde": 0,
      "tCl": "1.000000 1.000000 1.000000",
      "tAl": 2,
      "tSz": 60,
      "nme": "Current Slide",
      "typ": 1
    },
    {
      "ufr": "{{0.025000000000000001, 0.27440347071583515}, {0.40000000000000002, 0.10086767895878525}}",
      "mde": 1,
      "tCl": "1.000000 1.000000 1.000000",
      "tAl": 2,
      "tSz": 60,
      "nme": "Current Slide Notes",
      "typ": 3
    },
    {
      "ufr": "{{0.45000000000000001, 0.47396963123644253}, {0.29999999999999999, 0.40021691973969631}}",
      "mde": 0,
      "tCl": "1.000000 1.000000 1.000000",
      "tAl": 2,
      "tSz": 60,
      "nme": "Next Slide",
      "typ": 2
    },
    {
      "ufr": "{{0.45000000000000001, 0.37310195227765725}, {0.29999999999999999, 0.1019522776572668}}",
      "mde": 1,
      "tCl": "1.000000 1.000000 1.000000",
      "tAl": 2,
      "tSz": 60,
      "nme": "Next Slide Notes",
      "typ": 4
    },
    {
      "ufr": "{{0.77500000000000002, 0.37418655097613884}, {0.20000000000000001, 0.40130151843817785}}",
      "nme": "Chord Chart",
      "mde": 1,
      "typ": 9
    },
    {
      "ufr": "{{0, 0.89804772234273322}, {0.20060975609756099, 0.10303687635574837}}",
      "mde": 1,
      "tCl": "1.000000 1.000000 1.000000",
      "tAl": 2,
      "tSz": 200,
      "nme": "Clock",
      "typ": 6
    },
    {
      "ufr": "{{0.79878048780487809, 0.89696312364425168}, {0.20060975609756099, 0.10303687635574837}}",
      "mde": 1,
      "tCl": "1.000000 1.000000 1.000000",
      "tAl": 2,
      "tSz": 200,
      "nme": "Video Countdown",
      "typ": 8
    },
    {
      "ufr": "{{0.050000000000000003, 0.024945770065075923}, {0.90000000000000002, 0.10086767895878525}}",
      "fCl": "0.135296 1.000000 0.024919",
      "mde": 1,
      "tCl": "1.000000 1.000000 1.000000",
      "tAl": 2,
      "fCh": true,
      "tSz": 60,
      "nme": "Message",
      "typ": 5
    }
  ],
  "ovr": false,
  "acn": "sl",
  "nme": "Static Current - Static Next"
}
```

* `acn` of `sl` indicates this is a single stage layout

### Request Current Stage Display Layout

COMMAND TO SEND:

```javascript
{"acn":"psl"}
```

EXPECTED RESPONSE (also used when stage display is updated):

```javascript
{"acn":"psl","uid":"[STAGE DISPLAY UID]"}
```

### Request Frame Values for Stage Display

COMMAND TO SEND:

```javascript
{"acn":"fv","uid":"[STAGE DISPLAY UID"}
```

### On New Live Slide Frame

```javascript
{
  "RVLiveStream_action": "RVLiveStream_frameData",
  "RVLiveStream_frameDataLength": 14625,
  "RVLiveStream_frameData": "/9j//gAQTGF2YzU3LjUzLjEwMAD/2wBDAAgEBAQEBAUFBQUFBQYGBgYGBgYGBgYGBgYHBwcICAgHBwcGBgcHCAgICAkJCQgICAgJCQoKCgwMCwsODg4RERT/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsBAAMBAQEBAQEBAQEAAAAAAAABAgMEBQYHCAkKCxAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6EQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/wAARCAEOAeADASIAAhIAAxIA/9oADAMBAAIRAxEAPwDwqiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKKAAAooooAACiiigAAKKKOtAAAUUux/7p/I0bH/ALp/I0AACUUux/7p/I0bH/un8jQAAJRS7H/un8jRsf8Aun8jQAAJRS7H/un8jRsf+6fyNAAAlFLsf+6fyNGx/wC6fyNAAAlFLsf+6fyNGx/7p/I0AACUUux/7p/I0bH/ALp/I0AACUUux/7p/I0bH/un8jQAAJRS7H/un8jRsf8Aun8jQAAJRS7H/un8jRsf+6fyNAAAlFLsf+6fyNGx/wC6fyNAAAlFLsf+6fyNGx/7p/I0AACUUux/7p/I0bH/ALp/I0AACUUux/7p/I0bH/un8jQAAJRS7H/un8jRsf8Aun8jQAAJRS7H/un8jRsf+6fyNAAAlFLsf+6fyNGx/wC6fyNAAAlFLsf+6fyNGx/7p/I0AACUUux/7p/I0bH/ALp/I0AACUUux/7p/I0bH/un8jQAAJRS7H/un8jRsf8Aun8jQAAJRS7H/un8jRsf+6fyNAAAlFLsf+6fyNGx/wC6fyNAAAlFLsf+6fyNGx/7p/I0AACUUux/7p/I0bH/ALp/I0AACUUux/7p/I0bH/un8jQAAJRRRQAAFFFFAAAUUUUAABXafs9wQXPxg8LRTxRzRtcT7o5EV0b/AEWY8qwIPPqK4uu2/Z0/5LL4U/6+bj/0kmoAAPrL/hH9B/6BOm/+Adv/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"
}
```

* Base64 Encoded Image Bytes
* Only the Current Slide can be "Live"
* Live slide images are pushed to the client over the websocket.

### To Get Static Slide Images

TO RETRIEVE STATIC SLIDE IMAGES:

Issue a normal GET request to the following URL:

http://PROPRESENTER_IP:PROPRESENTER_PORT/stage/image/SLIDE_UID

EXPECTED RESPONSE:

normal jpeg image

### On New Time

EXPECTED RESPONSE:

```javascript
{"acn":"sys","txt":" 11:17 AM"}
```

### On Timer Update

EXPECTED RESPONSE:

```javascript
{ acn: 'tmr',
  uid: '[TIMER UID]',
  txt: '--:--:--' }
```

### On New Slide

EXPECTED RESPONSE:

```javascript
{
	"acn": "fv",
	"ary": [
		{
			"acn": "cs",			# CURRENT SLIDE
			"uid": "[SLIDE UID]",
			"txt": "[SLIDE TEXT]"
		},
		{
			"acn": "ns",			# NEXT SLIDE
			"uid": "[SLIDE UID]",
			"txt": "[SLIDE TEXT]"
		},
		{
			"acn": "csn",			# CURRENT SLIDE NOTES
			"txt": "[SLIDE NOTES]"
		},
		{
			"acn": "nsn",			# NEXT SLIDE NOTES
			"txt": "[SLIDE NOTES]"
		}
	]
}
```
