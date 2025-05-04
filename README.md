# ☢️ Beta - A Minimal Reactive Logic Library for Roblox

**Beta** is a tiny, type-safe, and reactive utility library inspired by [Fusion](https://elttob.uk/Fusion/) and functional UI paradigms. It lets you build reactive state, derived values, and respond to changes cleanly.

---

## 📦 Features

* 🔁 **Reactive state** with `.respond()` listeners
* 🔍 **Derived values** via `evaluate()` that auto-track dependencies
* 🔒 Full error handling and type safety

---

## 🛠️ Installation

> Place the `beta` folder inside `ReplicatedStorage` or another shared location in your game.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local beta = require(ReplicatedStorage.beta)

local state = beta.state
local evaluate = beta.evaluate
```

---

## 🔧 API

### `state(initialValue) -> state<T>`

Create a reactive state value. Call the state with no arguments to read the state, and call it with an argument to modify the state.

> Calling the state with a second parameter of a boolean will determine whether to force any evaluations to respond. Please see below for more information.

```lua
local health = state(100)

-- Reading
print(health()) --> 100

-- Responding
health:respond(function(old, new)
	print("Health changed from", old, "to", new)
end)

-- Updating
health(90)
```

---

### `evaluate(fn) -> evaluate<T>`

Create a derived value from other states. 

> evaluate uses a distinctUntilChanged behaviour to calculate evaluations - only re-evaluating when the new value is different to the old value. This helps peformance and reduced memory usage. You can read about it [here](https://www.learnrxjs.io/learn-rxjs/operators/filtering/distinctuntilchanged).

```lua
local health = state(80)
local status = evaluate(function()
	return health() > 50 and "Healthy" or "Injured"
end)

print(status()) --> "Healthy"
status:disconnect() -- Disconnectable evaluations
```

Auto-updates when `health` changes.

---

