/* dt_smooth_test.c -- dt_smooth_step() on synthetic frame times. The step is
 * the real code between DT_SMOOTH_BEGIN and DT_SMOOTH_END in recomp_manual.c;
 * run_dt_smooth_test.sh extracts it to a header (DT_BLOCK).
 * Usage: dt_smooth_test [-v]   (-v prints every frame) */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include DT_BLOCK

#define MAXF 1024
#ifndef SEEDBASE
#define SEEDBASE 777u
#endif

static int fails, verbose;
static unsigned rng = 12345u;

static double rnd(void)                 /* 0..1, fixed seed */
{
    rng = rng * 1664525u + 1013904223u;
    return (double)(rng >> 8) / (double)(1u << 24);
}
static double jit(double c, double a) { return c + (rnd() * 2.0 - 1.0) * a; }

typedef struct {
    int n, odd, fixes;
    double max_debt, max_out, min_out;
} res_t;

/* Run the smoother on in[] (in V). out[] gets the result (in V). odd counts
 * outputs further than 0.01 V from exp, from frame skip on. */
static res_t run(const char *name, const double *in, int n, double exp, int skip)
{
    dt_smooth_t s;
    res_t r;
    int i;
    memset(&s, 0, sizeof s);
    memset(&r, 0, sizeof r);
    r.n = n;
    r.min_out = 1e9;
    for (i = 0; i < n; i++) {
        double o = dt_smooth_step(&s, (float)(in[i] * DT_V), 6.0f * DT_V, 0) / DT_V;
        if (verbose)
            printf("  %s %3d in %.3f out %.3f debt %+.3f\n", name, i, in[i], o, s.debt / DT_V);
        if (i >= skip && fabs(o - exp) > 0.01)
            r.odd++;
        if (o > r.max_out) r.max_out = o;
        if (o < r.min_out) r.min_out = o;
    }
    r.fixes = (int)s.fixes;
    r.max_debt = s.max_debt / DT_V;
    printf("%-26s frames %3d odd %3d fixes %3d max|debt| %.2f V out %.2f..%.2f V\n",
           name, r.n, r.odd, r.fixes, r.max_debt, r.min_out, r.max_out);
    return r;
}

#define CHECK(c) do { if (!(c)) { fails++; \
    printf("FAIL %s:%d: %s\n", __FILE__, __LINE__, #c); } } while (0)

static int fill_steady(double *d, int n, double c, double a)
{
    int i;
    for (i = 0; i < n; i++) d[i] = jit(c, a);
    return n;
}

/* a: steady 30 fps, then pairs, then steady. */
/* wide: two long frames in a row are 3.8 V of debt at once; allow more. */
static void case_a(const char *name, const double *pat, int plen, int reps, int wide)
{
    double d[MAXF];
    int n = 0, i, r;
    res_t x;
    n += fill_steady(d + n, 40, 2.0, 0.08);
    for (r = 0; r < reps; r++)
        for (i = 0; i < plen; i++) d[n++] = pat[i];
    n += fill_steady(d + n, 40, 2.0, 0.08);
    x = run(name, d, n, 2.0, 0);
    CHECK(x.odd * (wide ? 10 : 50) <= x.n);     /* at most 2 % (10 %) off-step */
    CHECK(x.max_debt < (wide ? 3.5 : 2.5));
    CHECK(x.fixes * (wide ? 10 : 50) <= x.n);   /* payments rare */
}

/* b: 300 frames; each slot is a pair with probability pp. */
static void case_b(const char *name, double pp, int heavy)
{
    double d[MAXF];
    int n = 0;
    res_t x;
    while (n < 300) {
        if (rnd() < pp && n + 2 <= 300) {
            double l = 3.0 + rnd();
            double sh = 3.9 + (rnd() - 0.5) * 0.2 - l;
            if (sh < 0.0) sh = 0.0;
            if (sh > 1.0) sh = 1.0;
            if (rnd() < 0.5) { d[n++] = l; d[n++] = sh; }
            else { d[n++] = sh; d[n++] = l; }
        } else {
            d[n++] = jit(2.0, 0.08);
        }
    }
    x = run(name, d, n, 2.0, 0);
    CHECK(x.odd * (heavy ? 20 : 50) <= x.n);    /* at most 2 % (5 %) off-step */
    CHECK(x.max_debt < 3.0);
    CHECK(x.fixes * (heavy ? 20 : 50) <= x.n);
}

int main(int argc, char **argv)
{
    static const double p1[] = {3.9, 0.1}, p2[] = {0.1, 3.9};
    static const double p3[] = {3.9, 3.9, 0.1, 0.1}, p4[] = {4.0, 0.05, 3.95, 0.0};
    double d[MAXF];
    res_t x;
    int n, i;

    verbose = argc > 1 && strcmp(argv[1], "-v") == 0;

    /* (a) 30 fps with long/short pairs */
    case_a("a1 long,short x6", p1, 2, 6, 0);
    case_a("a2 short,long x6", p2, 2, 6, 0);
    case_a("a3 L,L,s,s x3", p3, 4, 3, 1);
    case_a("a4 4.0,.05,3.95,0 x3", p4, 4, 3, 0);

    /* (b) 30 fps, device mix: long/short pairs (long 3..4 V, short 0..1 V,
     * sum about 4 V) in 14 % and 36 % of the frames, 3 seeds each */
    for (i = 0; i < 6; i++) {
        char nm[32];
        rng = SEEDBASE + 31u * (unsigned)i;
        snprintf(nm, sizeof nm, "b%d mix %d%%", i, i < 3 ? 14 : 36);
        case_b(nm, i < 3 ? 0.075 : 0.22, i >= 3);
    }

    /* (c) 60 fps: the output is V, V and the debt never pays */
    for (n = 0; n < 200; n++) d[n] = 1.0 + ((n & 1) ? 0.06 : -0.06);
    for (i = 0; i < 6; i++) {
        int j;
        d[n++] = 1.9; d[n++] = 0.1;
        for (j = 0; j < 12; j++) d[n++] = 1.0 + ((j & 1) ? 0.06 : -0.06);
    }
    x = run("c 60 fps pairs", d, n, 1.0, 0);
    CHECK(x.odd == 0);
    CHECK(x.max_debt < 1.5 + 1e-6);

    /* (d) sustained drop and 60 -> 30 fps switch */
    n = fill_steady(d, 40, 2.0, 0.05);
    n += fill_steady(d + n, 30, 3.0, 0.05);
    n += fill_steady(d + n, 40, 2.0, 0.05);
    {
        dt_smooth_t s;
        float o3 = 0.0f, o2 = 0.0f;
        memset(&s, 0, sizeof s);
        for (i = 0; i < n; i++) {
            float o = dt_smooth_step(&s, (float)(d[i] * DT_V), 6.0f * DT_V, 0) / DT_V;
            if (i == 69) o3 = o;        /* last frame of the 3 V run */
            if (i == n - 1) o2 = o;
        }
        printf("%-26s out at drop end %.2f V, at end %.2f V\n", "d1 2V,3V x30,2V", o3, o2);
        CHECK(fabsf(o3 - 3.0f) < 0.01f);
        CHECK(fabsf(o2 - 2.0f) < 0.01f);
    }
    n = fill_steady(d, 60, 1.0, 0.05);
    n += fill_steady(d + n, 60, 2.0, 0.05);
    {
        dt_smooth_t s;
        float o1 = 0.0f, o2 = 0.0f;
        memset(&s, 0, sizeof s);
        for (i = 0; i < n; i++) {
            float o = dt_smooth_step(&s, (float)(d[i] * DT_V), 6.0f * DT_V, 0) / DT_V;
            if (i == 59) o1 = o;
            if (i == n - 1) o2 = o;
        }
        printf("%-26s out before %.2f V, at end %.2f V\n", "d2 1V -> 2V", o1, o2);
        CHECK(fabsf(o1 - 1.0f) < 0.01f);
        CHECK(fabsf(o2 - 2.0f) < 0.01f);
    }

    /* (e) one 5 V hitch in steady 2 V: no runaway */
    n = fill_steady(d, 40, 2.0, 0.05);
    d[n++] = 5.0;
    n += fill_steady(d + n, 40, 2.0, 0.05);
    x = run("e hitch 5V", d, n, 2.0, 0);
    CHECK(x.max_debt < 3.5);
    CHECK(x.max_out <= 3.0 + 0.01);     /* catch-up of at most 1 V */
    {
        dt_smooth_t s;                  /* the debt is gone by the end */
        float o = 0.0f;
        memset(&s, 0, sizeof s);
        for (i = 0; i < n; i++)
            o = dt_smooth_step(&s, (float)(d[i] * DT_V), 6.0f * DT_V, 0) / DT_V;
        CHECK(fabsf(o - 2.0f) < 0.01f);
        CHECK(fabs(s.debt / DT_V) < 2.5 + 1e-6);   /* bounded, no runaway */
    }

    if (fails) {
        printf("dt_smooth_test: %d FAILED\n", fails);
        return 1;
    }
    printf("dt_smooth_test: ok\n");
    return 0;
}
