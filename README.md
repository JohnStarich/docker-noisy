# noisy
Noisy prints out a lot

## Print stuff

```bash
docker run johnstarich/noisy
# or
docker run johnstarich/noisy 3.14
# or
docker run johnstarich/noisy 42 '{{time}} Hello world!'
# where {{time}} is replaced with the current time stamp
```

Usage: `noisy SLEEP_TIME [LOG_MESSAGE]`

* SLEEP_TIME - Number of seconds to wait between logs. Default is 5 seconds.
* LOG_MESSAGE - Optional. The message to print every SLEEP_TIME seconds. Use `{{time}}` in the string for current time. Default is a JSON log.
