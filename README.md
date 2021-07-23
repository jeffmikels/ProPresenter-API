# ProPresenter-API

Documenting RenewedVision's undocumented network protocols with examples

See below for changes to this repository:

For ProPresenter 6, go here:
https://jeffmikels.github.io/ProPresenter-API/Pro6/

For ProPresenter 7, go here:
https://jeffmikels.github.io/ProPresenter-API/Pro7/

For a Node Library implementing this protocol, go here:
https://github.com/utopiantools/node-propresenter.git

or

```
npm install https://github.com/utopiantools/node-propresenter.git
```

For an example of a real app built with node.js that uses this API to turn ProPresenter into a universal remote control:
https://github.com/jeffmikels/propresenter-watcher

For documentation regarding the new Pro7 file format:
https://github.com/greyshirtguy/ProPresenter7-Proto

## CHANGES

Recently, I have begun to migrate all the documentation into machine-readable formats
so that as the Pro7 API improves, we will be able to more readily track the changes.

It is also my hope that this effort will inspire RenewedVision to join the documentation
effort directly.

## API METHODOLOGY

AsyncAPI is a great system for defining APIs and for generating code and documentation, but editing it by hand
seemed cumbersome to me, so I built my own solution.

1. I converted our former Markdown documentation files into a `api.yaml` format that is inspired by AsyncAPI, but is more easily edited.
2. I wrote a Python script to automatically convert my `api.yaml` files into AsyncAPI 2.1.0 files.
3. I use the AsyncAPI command line generator commands to render out html files.

## API.YAML SPECIFICATIONS

The `api.yaml` file begins with a section called `asyncapi`. That section may contain anything an AsyncAPI `2.1.0` file may contain.

Then, there is a `types` section that holds defined data types similar to the way AsyncAPI does schemas. These will be translated into AsyncAPI schema nodes.

Types are structured as follows:

```yaml
typename:
    type: |-
        can be a built-in type like

        `integer`, `string`, `number`, `list`, `list[othertype]`, or `object`

        or it can be another defined type or list[othertype]
    parameters:
        field_1:
            type: typename
        field_2: constantvalue
        field_3:
            type: typename
            options: [option1, option2, option3]
            description: "each field can have a description"
            examples: ["each field can have an example"]
    example:
        field_1: an arbitrary value
        field_2: constantvalue
        field_3: option1
```

Then, there is the `channels` section which defines the main application message endpoints. ProPresenter exposes two channels, `/remote` and `/stagedisplay`.

Each `channel` is structured as follows:

```yaml
channels:
    channelname:
        summary: Simple name for this channel
        description: |
            Block markdown content describing this channel in detail
            actions: "list of actions, see below"
```

Each `channel` has a list of `actions` that can be sent or received.

Actions may contain a `message` and or `response` and are structured as follows (NOTE: `payload` and `example` follow the same structure as a type, and the `example` must match the payload structure):

```yaml
actionName:
    summary: simple name for this action
    description: markdown text describing this action
    message:
        payload:
            action: actionName
            field_2: someConstantValue
            field_3:
                type: string
                options: ["1", "2", "3"]
                example: "2"
                description: textual description
        example:
    response:
        payload:
        example:
```

# CONTRIBUTING

To contribute, please just edit the `api.yaml` file. I will regenerate the other documentation myself until I get Github actions working.
