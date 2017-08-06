# redux-async-dispatch

Is there a simple way to dispatch actions asynchronously using Tasks and maybe
a task middleware?

```
const fetchBar = kreeater.toSeries({
	loading: fetchBarRequest,
	success: fetchBarSuccess,
	err: fetchBarErr,
})((actionCreators, barId) => {
		actionCreators.loading();

		fetch(`/bars/${barId}`)
		.then(bar => actionCreators.success(bar))
		.catch(err => actionCreators.err(err));
	}
));
const fetchBar = kreeater.fromTask().chain()
```
