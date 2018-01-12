# ProPresenter-RemoteControl
Documenting RenewedVision's undocumented Remote Control protocol with examples

The ProPresenter Remote Control protocol is an unencrypted text-based websocket connection from the client to the ProPresenter instance.

## Connecting

```javascript
ws://[host]:[port]/remote
```

## Authenticate

SEND:

```javascript
{"action":"authenticate","protocol":"600","password":"control"}
```
RECEIVE:

```javascript
{"controller":1,"authenticated":1,"error":"","action":"authenticate"}
```

## Get Library

SEND:

```javascript
{"action":"libraryRequest"}
```

RECEIVE:

```javascript
{"library":[array of pathnames],"action":"libraryRequest"}
```

## Get All Playlists

SEND:

```javascript
{"action":"playlistRequestAll"}
```

RECEIVE:

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

## Request Presentation

SEND:

```javascript
{
    "action": "presentationRequest",
    "presentationName": "Song 1 Title",
    "presentationPath": "/Users/Documents/ProPresenter6/Song 1 Title.pro6",
    "presentationSlideQuality": 25
}
```

`presentationSlideQuality` determines the resolution / size of the slide previews sent from ProPresenter.

RECEIVE:

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

## Get Index of Current Slide

SEND:

```javascript
{"action":"presentationSlideIndex"}
```
RECEIVE:

```javascript
{"action":"presentationSlideIndex","slideIndex":"0"}
```
## Trigger Slide

SEND:

```javascript
{"action":"presentationTriggerIndex","slideIndex":3,"presentationPath":"[SLIDE PATH]"}
```

RECEIVE:

```javascript
{"slideIndex":3,"action":"presentationTriggerIndex","presentationPath":"[SLIDE PATH]"}
```
