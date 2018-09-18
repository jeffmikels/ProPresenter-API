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
{"library":[array of pathnames],"action":"libraryRequest"}
```

### Get All Playlists

COMMAND TO SEND:

```javascript
{"action":"playlistRequestAll"}
```

EXPECTED RESPONSE:

This request returns a large amount of data similar to the following

```javascript
{
    "playlistAll": [
        {
            "playlistLocation": "1",
            "playlistType": "playlistTypePlaylist",
            "playlistName": "Testing",
            "playlist": [
                {
                    "playlistItemName": "Song 1 Title",
                    "playlistItemLocation": "1:0",
                    "playlistItemType": "playlistItemTypePresentation"
                },
                {
                    "playlistItemName": "Song 2 Title",
                    "playlistItemLocation": "1:1",
                    "playlistItemType": "playlistItemTypePresentation"
                }
            ]
        },
    "action": "playlistRequestAll"
}
```

### Request Presentation (set of slides)

COMMAND TO SEND:

```javascript
{
    "action": "presentationRequest",
    "presentationName": "Song 1 Title",
    "presentationPath": "/Users/Documents/ProPresenter6/Song 1 Title.pro6",
    "presentationSlideQuality": 25
}
```

`presentationSlideQuality` determines the resolution / size of the slide previews sent from ProPresenter.

EXPECTED RESPONSE:

```javascript
{
    "action": "presentationCurrent",
    "presentation": {
        "presentationSlideGroups": [
            {
                "groupName": "[SLIDE GROUP]",
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
        "presentationName": "[SONG TITLE]",
        "presentationHasTimeline": 0,
        "presentationCurrentLocation": "[SONG PATH]"
    }
}
```

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
{"action":"presentationTriggerIndex","slideIndex":3,"presentationPath":"[SLIDE PATH]"}
```

EXPECTED RESPONSE:

```javascript
{"slideIndex":3,"action":"presentationTriggerIndex","presentationPath":"[SLIDE PATH]"}
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