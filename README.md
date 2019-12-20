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
    "/Path/To/ProPresenter/Library/Come Alive (Dry Bones).pro6",
    "/Path/To/ProPresenter/Library/Pour Out My Heart.pro6",
    "/Path/To/ProPresenter/Library/Away in a manger.pro6",
	"... ALL PRESENTATIONS IN THE LIBRARY ..."
  ],
  "action": "libraryRequest"
}
```

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
    "presentationPath": "/Path/To/ProPresenter/Library/Song 1 Title.pro6",
    "presentationSlideQuality": 25
}
```

* `presentationPath` is required but need not be the full path of the presentation. Specifying the filename (eg. `Song 1 Title.pro6`) is good enough.
* `presentationSlideQuality` is optional. It determines the resolution / size of the slide previews sent from ProPresenter. If left blank, high quality previews will be sent. If set to `0` previews will not be generated at all. A good compromise is `25`.

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
        "presentationCurrentLocation": "[PRESENTATION PATH]"
    }
}
```

* NOTE: the response contains `presentationCurrent` as the action instead of `presentationRequest`. This seems to be a bug in the ProPresenter response.

### Request Current Presentation

COMMAND TO SEND:

```javascript
{
	"action":"presentationCurrent",
    "presentationSlideQuality": 25
}
```

EXPECTED RESPONSE:

Same response as `requestPresentation`

* NOTE: This action only works if there is an *active slide*. When ProPresenter starts, no slide is marked active, so this action *returns nothing until a slide has been triggered*.


### Get Index of Current Slide

COMMAND TO SEND:

```javascript
{"action":"presentationSlideIndex"}
```
EXPECTED RESPONSE:

```javascript
{"action":"presentationSlideIndex","slideIndex":"0"}
```

### Trigger Slide

COMMAND TO SEND:

```javascript
{"action":"presentationTriggerIndex","slideIndex":3,"presentationPath":"[PRESENTATION PATH]"}
```

EXPECTED RESPONSE:

```javascript
{"slideIndex":3,"action":"presentationTriggerIndex","presentationPath":"[PRESENTATION PATH]"}
```


## Stage Display

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
