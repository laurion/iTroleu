#include "dijkstra.h"
#include "strcmp95.c"
 
int Nr_Stations, Nr_Lines;

station stations[MAX_STATIONS];
char lines_name[MAX_LINES][MAX_LINE_NAME];
vector <int> linesG[MAX_LINES][2];
int nextStation[MAX_LINES][MAX_STATIONS][2];
vector < pair < pair <int, int>, int > > next_buses[MAX_STATIONS];

double sol[MAX_STATIONS][MAX_LINES][2];
        
void read_stations() {
  FILE *stations_file;
  int i;

  stations_file = fopen("stations.in", "r");

  assert(fscanf(stations_file, "%d\n", &Nr_Stations) == 1);
  
  for (i = 0; i < Nr_Stations; ++ i) {
    fgets(stations[i].name, MAX_STATION_NAME, stations_file);
    assert(fscanf(stations_file, "%lf%lf\n", 
          &stations[i].c.lat, &stations[i].c.lng) == 2);
    strtok(stations[i].name, "\n");
    lowercase(stations[i].name);
  }
  fclose(stations_file);
}

void read_lines() {
  int i, j, k, x, nr, station_id, cnt = 0, cnt2 = 0;
  char station_name[MAX_STATION_NAME];
  FILE *lines_file;

  lines_file = fopen("routes.out", "r");
  assert(fscanf(lines_file, "%d\n", &Nr_Lines) == 1);
  
  for (i = 0; i < Nr_Lines; ++ i) {
    fgets(lines_name[i], MAX_LINE_NAME, lines_file);
    strtok(lines_name[i], "\n");
    
    for (j = 0; j < 2; ++ j) {
      fscanf(lines_file, "%d", &nr);
      for (k = 1; k <= nr; ++ k) {
        fscanf(lines_file, "%d", &x);
        linesG[i][j].push_back(x);
      }
    }
  }
  fclose(lines_file);
}

vector <int> get_near_points(double x, double y) {
  vector < pair <double, int> > aux;
  int i;
  for (i = 0; i < Nr_Stations; ++ i) {
    coord now;
    now.lat = x; now.lng = y;
    double d = my_distance(now, stations[i].c);
    aux.push_back(make_pair(d, i));
  }

  sort(aux.begin(), aux.end());

  vector <int> ret;
  for (i = 0; i < min((int)aux.size(), 10); ++ i) {
    ret.push_back(aux[i].second);
  }
  return ret;
}

vector <pair <int, int> > ce_linii_trec[MAX_STATIONS];

void preprocesare() {
  for (int i = 0; i < Nr_Lines; ++ i) {
    for (int k = 0; k < 2; ++ k)
      for (vector <int> ::iterator it=linesG[i][k].begin(); it != linesG[i][k].end(); ++it) {
        vector <int> ::iterator next = (it + 1);
        nextStation[i][*it][k] = (next == linesG[i][k].end()) ? -1 : *next;
      }
  }

  for (int i = 0; i < Nr_Lines; ++ i) {
    for (int k = 0; k < 2; ++ k)
      for (vector <int> ::iterator it=linesG[i][k].begin(); it != linesG[i][k].end(); ++it) {
        vector <int> ::iterator next = (it + 1);
        ce_linii_trec[*it].push_back(make_pair(i, k));

        if (next != linesG[i][k].end()) {
          next_buses[*it].push_back(make_pair(make_pair(i, 2), *next));
        }
      }
  }
}

set < pair < double, pair < pair <int, int>, int > > > S;

int main () {
  coord current_point; current_point.lat = 44.386124; current_point.lng = 26.07797;
  read_stations();
  read_lines();
  vector <int> near_points = get_near_points(current_point.lat, current_point.lng);

  for (int i = 0; i < (int) near_points.size(); ++ i) {
    printf("(%lf %lf)", stations[near_points[i]].c.lat, stations[near_points[i]].c.lng);
  }
  
  preprocesare();

  for (int i = 0; i < Nr_Stations; ++ i) {
    for (int j = 0; j < Nr_Lines; ++ j) {
      for (int k = 0; j < 2; ++ k) {
        sol[i][j][k] = INF;
      }
    }
  }


  for (int i = 0; i < (int) near_points.size(); ++ i) {
    int station = near_points[i];
    double dist = my_distance(current_point, stations[station].c);

    for (int k = 0; k < (int) ce_linii_trec[station]; ++ k) {
      S.insert(make_pair(dist, make_pair( make_pair(near_points[i], ce_linii_trec[station][k]), 0)));
      S.insert(make_pair(dist, make_pair( make_pair(near_points[i], ce_linii_trec[station][k]), 1)));
    }
  }
  return 0;
}
