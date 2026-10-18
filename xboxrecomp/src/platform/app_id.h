/* app_id.h -- what the shared runtime asks of the game shell.
 *
 * The game (src/main.c) defines the three functions. The runtime includes
 * no game header: it gets the name of the game, the old name for file
 * fallbacks and the per-game panel defaults through these calls. */
#ifndef XBOX_APP_ID_H
#define XBOX_APP_ID_H

#include <stdarg.h>
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Short lower-case game id: "nfsu2", "nfsu1". It prefixes log lines and the
 * file names in Documents (<id>_log.txt, <id>_env.txt, <id>_touch_layout_*). */
const char *xbox_app_id(void);

/* The id that older builds of this game used for those files, or NULL when
 * it never changed. A missing settings or layout file is read again under
 * this id. Writes always use xbox_app_id(). */
const char *xbox_app_legacy_id(void);

/* Panel default of a switch row. Returns the game's own default for the
 * settings key, or def when the game has none for it. */
int xbox_app_default_on(const char *key, int def);

/* One log line to stderr, "<id>: " first. One write per call, so lines of
 * different threads do not mix. */
#if defined(__GNUC__)
__attribute__((format(printf, 1, 2)))
#endif
static inline void xbox_app_log(const char *fmt, ...)
{
    char buf[2048];
    va_list ap;
    int n = snprintf(buf, sizeof buf, "%s: ", xbox_app_id());

    if (n < 0 || n >= (int)sizeof buf)
        n = 0;
    va_start(ap, fmt);
    vsnprintf(buf + n, sizeof buf - (size_t)n, fmt, ap);
    va_end(ap);
    fputs(buf, stderr);
}

#ifdef __cplusplus
}
#endif

#endif /* XBOX_APP_ID_H */
