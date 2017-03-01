# Unwind

Unwind is a JSON parsing library inspired by Argo and several others.

It still has a lot of work left to do but the basics are there.

Unwind can do a lot of really cool things. For example take the following JSON.

```JSON
{
	"someDate": "January 23, 1990",
	"someString": "Hello World",
	"someInt": 18,
	"someStringInt": "21",
	"user": {
		"name": "John",
		"age": "23"
	},
	"settings": {
		"nightMode": true
	}
}
```

Here is some of the things you can do:

```Swift

let date: Date = json <- "someDate"
let str: String? = json <-? "someString"
let num: Int = json <- "someInt"

//Automatically detect type should be int and convert from string.
let strInt: Int = json <- "someStringInt"

struct User {
    let name: String
    let age: Int
}

extension User: Unwind {
    init(json: JSON) {
        name = json <- "name"
        age = json <- "age"
    }
}

let user: User = json <- "user"

//Nested objects
let method1: Bool = "settings.nightMode"
let method2: Bool = ["settings", "nightMode"]

```
## License
Unwind is released under the MIT license. Check LICENSE.md for details

