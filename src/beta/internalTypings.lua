export type state<T> = {
	__call: (self: state<T>, newValue: T?, forceUpdate: boolean?) -> T,
	respond: (self: state<T>, callback: (oldValue: T, newValue: T) -> ()) -> (() -> ()),
}

export type evaluate<T> = {
	__call: (self: evaluate<T>) -> T,
	disconnect: (self: evaluate<T>) -> (),
	value: T,
}

return nil
