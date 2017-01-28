using System;
using System.Threading;

public static void Run(TimerInfo myTimer, TraceWriter log, CancellationToken token)
{
    var duration = TimeSpan.FromSeconds(30);
    var start = DateTime.Now;
    while (true)
    {
        var now = DateTime.Now;
        log.Info($": {now:yyyy/MM/dd HH:mm:ss.fff}");

        if (token.IsCancellationRequested)
            log.Info($": cancelled");

        if (now - start > duration)
            break;

        Thread.Sleep(500);
    }

    var end = DateTime.Now;
    log.Info($": start:{start:yyyy/MM/dd HH:mm:ss.fff}, end:{end:yyyy/MM/dd HH:mm:ss.fff}");

}