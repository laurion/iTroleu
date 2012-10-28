#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include <assert.h>
#include <ctype.h>
#include <vector>
#include <set>
#include <utility>
#include <algorithm>

using namespace std;
#define PI 3.14159265358979323846
#define MAX_STATIONS 1200
#define MAX_LINES 400
#define MAX_STATION_NAME 64
#define MAX_LINE_NAME 10
#define INF 284828482

 /* Disable both */
//int jaro_ind_c = **jaro_ind_c;

struct coord {
  double lat;
  double lng;
};
typedef struct coord coord;

struct station {
  coord c;
  char name[MAX_STATION_NAME];
  /* Needed for preprocessing names (optimization) 
   * Used for computing strcmp95 */
};
typedef struct station station;

double my_distance(coord x, coord y) {
  //main code inside the class
  double dlat1 = x.lat * (PI / 180);
  double dlong1 = x.lng * (PI / 180);

  double dlat2 = y.lat * (PI / 180);
  double dlong2 = y.lng * (PI / 180);

  double dLong = dlong1 - dlong2;
  double dLat = dlat1 - dlat2;

  // Some voodoo magic
  double aHarv = pow(sin(dLat / 2.0), 2.0) + cos(dlat1) * cos(dlat2) * pow(sin(dLong / 2), 2);
  double cHarv = 2 * atan2(sqrt(aHarv), sqrt(1.0 - aHarv));
  const double earth=6378.137;
  double distance=earth*cHarv;

  return distance;
}

void lowercase(char *string) {
  char *p;
  for (p = string; *p; *p = tolower(*p), p++);
}
