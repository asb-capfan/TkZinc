/* Standalone regression test for #25. Run from the repository root:
 * cc -g -fsanitize=address -fno-omit-frame-pointer \
 *    tests/overlapman-memory.c -lm -o build/overlapman-memory
 * ./build/overlapman-memory
 * Include the implementation to exercise its internal track database.
 */
#include <assert.h>
#include "../generic/OverlapMan.c"

static char widgets[5], tracks[5];

static void *
NextTrack(void *widget, void *previous,
          int *x, int *y, int *dx, int *dy, int *rho, int *theta,
          int *visible, int *locked, int *preferred, int *convergence)
{
  (void)widget;
  *x = *y = *dx = *dy = *rho = *theta = 0;
  *locked = *preferred = *convergence = 0;
  *visible = TRUE;
  if (previous == NULL) return &tracks[1];
  if (previous == &tracks[1]) return &tracks[3];
  return NULL;
}

int
main(void)
{
  int i;
  NBzincs = NBalloc_zincs = 5;
  wr = calloc(5, sizeof(*wr));
  assert(wr != NULL);
  for (i = 0; i < 5; i++) {
    wr[i].rw = &widgets[i];
    wr[i].infos = calloc(5, sizeof(INFOS));
    assert(wr[i].infos != NULL);
    wr[i].NBinfos = wr[i].NBalloc_infos = 5;
  }

  /* Removing the first widget shifts four overlapping array elements. */
  OmUnregister(&widgets[0]);
  assert(NBzincs == 4);
  for (i = 0; i < 4; i++) assert(wr[i].rw == &widgets[i+1]);

  /* Refresh only two tracks: remove the first, middle and last entries. */
  for (i = 0; i < 5; i++) wr[0].infos[i].id = &tracks[i];
  wr[0]._next_track = NextTrack;
  ReadTracks(0);
  assert(wr[0].NBinfos == 2);
  assert(wr[0].infos[0].id == &tracks[1]);
  assert(wr[0].infos[1].id == &tracks[3]);

  OmUnregister(&widgets[2]);
  assert(NBzincs == 3);
  assert(wr[0].rw == &widgets[1]);
  assert(wr[1].rw == &widgets[3]);
  assert(wr[2].rw == &widgets[4]);
  OmUnregister(&widgets[4]);
  OmUnregister(&widgets[3]);
  OmUnregister(&widgets[1]);
  assert(NBzincs == 0);
  free(wr);
  return 0;
}
