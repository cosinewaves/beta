# Roadmap
Future updates planned for the *beta* library will be listed below. If you have any suggestions, send a PR modifying this folder and add your change.

---

## hook
hook is an instance creation module, similar to `Fusion.New` or `React.createElement()`. hook can take in evaluations and state's as properties for an instance's property table. if an evaluation is passed, the property it is assigned to will automatically update, creating a reactive element. state's will automatically be subscribed to using their built in `respond` method, and likewise with the evaluation - the assigned property will also be updated.

example code:
```lua
local beta = require(".../beta")
local hook = beta.hook
local state = beta.state
local evaluate = beta.evaluate

local nameState = state("Wall")
local colorEvaluation = evaluate(function()
  return math.random(1, 2) == 1 and Color3.fromRGB(125, 125, 125) or Color3.fromRGB(32, 32, 32)
end)

local myPart = hook("Part", {

  Name = nameState, -- state support
  Size = CFrame.new(1, 1, 1),
  Color = colorEvaluation, -- pre-defined evaluation support
  Position = evaluate(function() -- built-in evaluation support
    return Vector3.new(math.random(1, 100), math.random(1, 100), math.random(1, 100))
  end)

})

```
