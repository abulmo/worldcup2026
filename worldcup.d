#!/usr/bin/rdmd
module worldcup;

import std.algorithm, std.getopt, std.stdio, std.math, std.random;

struct Team {
	string name;
	double score;

	/** compare two teams */
	double opCmp(const Team other) const {
		return score - other.score;
	}
}

/**
 * The worldcup team ratings as of 2026/07/01
 * https://worldfootballrankings.com/rankings
 */

static immutable Team [] ELO = [
	{ "France", 1916.24 },
	{ "Argentine", 1913.71 },
	{ "Espagne", 1892.28 },
	{ "Angleterre", 1850.97 },
	{ "Brésil", 1804.92 },
	{ "Maroc", 1788.56 },
	{ "Portugal", 1787.85 },
	{ "Pays-Bas", 1775.84 },
	{ "Belgique", 1756.51 },
	{ "Mexique", 1754.30 },
	{ "Colombie", 1739.39 },
	{ "Allemagne", 1726.22 },
	{ "Croatie", 1723.05 },
	{ "Suisse", 1696.30 },
	{ "États-Unis", 1690.33 },
	{ "Japon", 1673.68 },
	{ "Sénégal", 1653.43 },
	{ "Uruguay", 1634.70 },
	{ "Norvège", 1617.67 },
	{ "Iran", 1609.85 },
	{ "Autriche", 1598.82 },
	{ "Égypte", 1597.04 },
	{ "Équateur", 1592.59 },
	{ "Turquie", 1582.54 },
	{ "Australie", 1581.51 },
	{ "Algérie", 1576.80 },
	{ "Canada", 1571.34 },
	{ "Côte d'Ivoire", 1565.47 },
	{ "Corée", 1558.72 },
	{ "Paraguay", 1542.48 },
	{ "Suède", 1525.58 },
	{ "RD Congo", 1495.48 },
	{ "Écosse", 1491.22 },
	{ "Panama", 1478.41 },
	{ "Tchéquie", 1467.26 },
	{ "Afrique du Sud", 1451.24 },
	{ "Tunisie", 1426.58 },
	{ "Arabie saoudite", 1425.52 },
	{ "Qatar", 1411.06 },
	{ "Ouzbékistan", 1409.473},
	{ "Bosnie-et-Herzégovine", 1408.93 },
	{ "Irak", 1404.17 },
	{ "Cap-Vert", 1402.97 },
	{ "Ghana", 1387.00 },
	{ "Jordanie", 1350.41 },
	{ "Curaçao", 1285.64 },
	{ "Nouvelle-Zélande", 1269.80 },
	{ "Haïti", 1264.58 },
];

/**
 * Complete pool results.
 */
static immutable Team [2][] POOL_RESULTS = [
	[ { "Mexique", 2 }, { "Afrique du Sud", 0 } ],
	[ { "Corée", 2 }, { "Tchéquie", 1 } ],
	[ { "Canada", 1 }, { "Bosnie-et-Herzégovine", 1 } ],
	[ { "États-Unis", 4 }, { "Paraguay", 1 } ],
	[ { "Qatar", 1 }, { "Suisse", 1 } ],
	[ { "Brésil", 1 }, { "Maroc", 1 } ],
	[ { "Haïti", 0 }, { "Écosse", 1 } ],
	[ { "Australie", 2 }, {"Turquie", 0 } ],
	[ { "Allemagne", 7 }, {"Curaçao", 1 } ],
	[ { "Pays-Bas", 2 }, {"Japon", 2 } ],
	[ { "Côte d'Ivoire", 2 }, { "Équateur", 0 } ],
	[ { "Suède", 5 }, { "Tunisie", 1 } ],
	[ { "Espagne", 0 }, { "Cap-Vert", 0} ],
	[ { "Belgique", 1 }, { "Égypte", 1} ],
	[ { "Arabie saoudite", 2 }, { "Uruguay", 2 } ],
	[ { "Iran", 1 }, { "Nouvelle-Zélande", 1 } ],
	[ { "France", 3 }, { "Sénégal", 1 } ],
	[ { "Irak", 1 }, { "Norvège", 4 } ],
	[ { "Argentine", 3 }, { "Algérie", 0 } ],
	[ { "Autriche", 3 }, { "Jordanie", 1 } ],
	[ { "Portugal", 1 }, { "RD Congo", 1 } ],
	[ { "Angleterre", 4 }, { "Croatie", 2 } ],
	[ { "Ghana", 1 }, { "Panama", 0 } ],
	[ { "Ouzbékistan", 1 }, { "Colombie", 3 } ],
	[ { "Tchéquie", 1 }, { "Afrique du Sud", 1 } ],
	[ { "Suisse", 4 }, { "Bosnie-et-Herzégovine", 1 } ],
	[ { "Canada", 6 }, { "Qatar", 0 } ],
	[ { "Mexique", 1 }, { "Corée", 0 } ],
	[ { "États-Unis", 2 }, { "Australie", 0 } ],
	[ { "Écosse", 0 }, { "Maroc", 1 } ],
	[ { "Brésil", 3 }, { "Haïti", 0 } ],
	[ { "Turquie", 0 }, { "Paraguay", 1 } ],
	[ { "Pays-Bas", 5 }, { "Suède", 1 } ],
	[ { "Allemagne", 2 }, { "Côte d'Ivoire", 1 } ],
	[ { "Équateur", 0 }, { "Curaçao", 0 } ],
	[ { "Tunisie", 0 }, { "Japon", 4 } ],
	[ { "Espagne", 4 }, { "Arabie saoudite", 0 } ],
	[ { "Belgique", 0 }, { "Iran", 0 } ],
	[ { "Uruguay", 2 }, { "Cap-Vert", 2 } ],
	[ { "Nouvelle-Zélande", 1 }, { "Égypte", 3 } ],
	[ { "Argentine", 2 }, { "Autriche", 0 } ],
	[ { "France", 3 }, { "Irak", 0 } ],
	[ { "Norvège", 3 }, { "Sénégal", 2 } ],
	[ { "Jordanie", 1 }, { "Algérie", 2 } ],
	[ { "Portugal", 5 }, { "Ouzbékistan", 0 } ],
	[ { "Angleterre", 0 }, { "Ghana", 0 } ],
	[ { "Panama", 0 }, { "Croatie", 1 } ],
	[ { "Colombie", 1 }, { "RD Congo", 0 } ],
	[ { "Suisse", 2 }, { "Canada", 1 } ],
	[ { "Bosnie-et-Herzégovine", 3 }, { "Qatar", 1 } ],
	[ { "Écosse", 0 }, { "Brésil", 3 } ],
	[ { "Maroc", 4 }, { "Haïti", 2 } ],
	[ { "Tchéquie", 0 }, { "Mexique", 3 } ],
	[ { "Afrique du Sud", 1 }, { "Corée", 0 } ],
	[ { "Équateur", 2 }, { "Allemagne", 1 } ],
	[ { "Curaçao", 0 }, { "Côte d'Ivoire", 2 } ],
	[ { "Tunisie", 1 }, { "Pays-Bas", 3 } ],
	[ { "Japon", 1 }, { "Suède", 1 } ],
	[ { "Turquie", 3 }, { "États-Unis", 2 } ],
	[ { "Paraguay", 0 }, { "Australie", 0 } ],
	[ { "Norvège", 1 }, { "France", 4 } ],
	[ { "Sénégal", 5 }, { "Irak", 0 } ],
	[ { "Uruguay", 0 }, { "Espagne", 1 } ],
	[ { "Cap-Vert", 0 }, { "Arabie saoudite", 0 } ],
	[ { "Nouvelle-Zélande", 1 }, { "Belgique", 5 } ],
	[ { "Égypte", 1 }, { "Iran", 1 } ],
	[ { "Panama", 0 }, { "Angleterre", 2 } ],
	[ { "Croatie", 2 }, { "Ghana", 1 } ],
	[ { "Colombie", 0 }, { "Portugal", 0 } ],
	[ { "RD Congo", 3 }, { "Ouzbékistan", 1 } ],
	[ { "Jordanie", 1 }, { "Argentine", 3 } ],
	[ { "Algérie", 3 }, { "Autriche", 3 } ],
];

/**
 * Team Reaching the round of 32 fixtures
 * DO NOT CHANGE THE ORDER OF THE TEAMS
 */

static immutable string [] FINAL_TEAMS = [
	"Allemagne", "Paraguay",
	"France", "Suède",
	"Afrique du Sud", "Canada",
	"Pays-Bas", "Maroc",
	"Portugal", "Croatie",
	"Espagne", "Autriche",
	"États-Unis", "Bosnie-et-Herzégovine",
	"Belgique", "Sénégal",
	"Brésil", "Japon",
	"Côte d'Ivoire", "Norvège",
	"Mexique", "Équateur",
	"Angleterre", "RD Congo",
	"Argentine", "Cap-Vert",
	"Australie", "Égypte",
	"Suisse", "Algérie",
	"Colombie", "Ghana",
];

/** List of countriues eliminated */
static immutable string[] ELIMINATED  = [
	"Afrique du Sud",
	"Allemagne", "Pays-Bas", "Japon",
	"Suède", "Côte d'Ivoire", "Équateur", 
	"RD Congo", "Bosnie-et-Herzégovine", "Sénégal",
	"Autriche", "Algérie", "Croatie", 
	"Australie", "Cap-Vert", "Ghana",
	// after round of 16
	"Canada", "Paraguay",
];

/** Pool struct */
struct Pool {
	char pool;
	string [4] teams;
}

static immutable Pool [] POOLS = [
	{ 'A', [ "Mexique", "Afrique du Sud", "Corée", "Tchéquie" ] },
	{ 'B', [ "Canada", "Bosnie-et-Herzégovine", "Qatar", "Suisse" ] },
	{ 'C', [ "Brésil", "Maroc", "Haïti", "Écosse" ] },
	{ 'D', [ "États-Unis", "Paraguay", "Australie", "Turquie" ] },
	{ 'E', [ "Allemagne", "Curaçao", "Côte d'Ivoire", "Équateur" ] },
	{ 'F', [ "Pays-Bas", "Japon", "Suède", "Tunisie" ] },
	{ 'G', [ "Belgique", "Égypte", "Iran", "Nouvelle-Zélande" ] },
	{ 'H', [ "Espagne", "Cap-Vert", "Arabie saoudite", "Uruguay" ] },
	{ 'I', [ "France", "Sénégal", "Irak", "Norvège" ] },
	{ 'J', [ "Argentine", "Algérie", "Autriche", "Jordanie" ] },
	{ 'K', [ "Portugal", "RD Congo", "Ouzbékistan", "Colombie" ] },
	{ 'L', [ "Angleterre", "Croatie", "Ghana", "Panama" ] },
];


/** Get the Elo of a team */
double getElo(string name) {	
	foreach (t; ELO) {
		if (t.name == name) return t.score;
	}
	
	return 0.0;
}

/** Number of goal expected frol the Difference in Elo rating
 * Based on a gross & very approximate estimation using the results of the pool results
 * and the ratings at that time. The curve explain only 30% of the variation. 
 * Params: eloDiff the Elo difference between the two teams
 * Return: the number of goal for that team
 */
double goalExpected(double eloDiff) {
	return clamp(2.3e-6 * eloDiff * eloDiff + 0.003 * eloDiff + 1.3, 0.0, 10.0);
}

/** 
 * Write the result of a match in the form "team1 score1 - score2 team2"
 */
void writeMatch(const Team [2] teams) {
	writefln("%s %.0f - %.0f %s", teams[0].name, teams[0].score, teams[1].score, teams[1].name);
}

/**
 * Write winning chance as percentage of the form "team1 win1% - win2% team2"
 * As knock-out game are played, the chance of drawing is shared between the two teams.
 * Params: teams The two teams participating at this match 
 */
void writePercentage(const Team [2] teams) {
	writefln("%s %.2f%% - %.2f%% %s", teams[0].name, teams[0].score * 100.0, teams[1].score * 100.0, teams[1].name);
}


/** Expected results between two teams */
Team[2] matchExpected(const string [] names) {
	double eloDiff = getElo(names[0]) - getElo(names[1]);
	double [] goals = [goalExpected(eloDiff), goalExpected(-eloDiff)];
	Team [2] teams =  [ { names[0], goals[0] }, { names[1], goals[1] } ];	

	return teams;
}

/** Write as a csv outpout the results of the pool phase with the Elo difference
 */
void writeEloScore() {
	writeln("team; Elo diff; score");
	foreach (teams; POOL_RESULTS) {
		double [] elos = [getElo(teams[0].name), getElo(teams[1].name)];
		writeln(teams[0].name, "; ", elos[0] - elos[1], "; ", teams[0].score);
		writeln(teams[1].name, "; ", elos[1] - elos[0], "; ", teams[1].score);
	}
}

/**
 * Write the probabilty to have a certain outcome 
 */
void writeProba() {
	double w, d , l;
	double [11][2] p;

	writefln("goal1; goal2; win%%; draw%%; loss%%");
	foreach (g0; 0 .. 30) {
		poisson(0.1 * g0, p[0]);
		foreach (g1; 0 .. g0 + 1) {
			poisson(0.1 * g1, p[1]);	
			w = d = l = 0.0;		
			foreach(i; 0 .. 11)
			foreach(j; 0 .. 11) {
				double q = p[0][i] * p[1][j];
				if (i > j) w += q;
				else if (i == j) d += q;
				else l += q;
			}
			writefln("%.1f; %.1f; %.3f%%; %.3f%%; %.3f%%", 0.1 * g0, 0.1 * g1, 100.0 * w, 100.0 * d, 100.0 * l);
		}
	}
}

/**
 * Write the average Elo for each pool of teams.
 */ 
void poolAverageElo() {
	foreach (p; POOLS) {
		double elo = 0.0;
		foreach(t; p.teams) {
			elo += getElo(t);
		}
		elo /= 4.0;
		writeln("Poule ", p.pool, " : ", elo);
	}
}

/** Get the result of a game in the pool, given two teams' names
	In case the 
	Params: names the two teams
	Result: the result of the matc weween the tow teams, or -1 -1 if not such match is available
 */
Team [2] getPoolResults(string [2] names) {
	
	foreach (r; POOL_RESULTS) {
		if (r[0].name == names[0] && r[1].name == names[1]) return r;
		if (r[0].name == names[1] && r[1].name == names[0]) return [r[1], r[0]];
	}
	Team [2] unknown = [{ names[0], -1 }, { names[1], -1 }];

	return unknown;
}

/**
 * Write the result & classsification of a pool
 * Params: pool the pool		if (isEliminated(p.names[0])) {
			p.l = 1.0; p.d = p.w = 0.0;
		} else if (isEliminated(p.names[1])) {
			p.w = 1.0; p.d = p.l = 0.0;
		} 
 to write the result from
 */
void writePool(Pool p) {
	struct TeamEx {
		string name;
		int w, d, l;
		double goalFor = 0.0, goalAgainst = 0.0;
		
		void print() {
			writefln("%24s, %4d, %4d, %4d, %4d, %6.0f, %6.0f, %+6.0f", name, 3 * w +d, w, d, l, goalFor, goalAgainst, goalFor - goalAgainst);
		}
		
		double opCmp(const ref TeamEx b) {
			double diff = 3 * w + d - 3 * b.w - b.d;
			if (diff == 0) diff = goalFor - goalAgainst + b.goalAgainst - b.goalFor;
			return diff;
		}
	}
	
	TeamEx [p.teams.length] teams;
	foreach(i ; 0 .. teams.length) teams[i].name = p.teams[i];
	foreach(i ; 0 .. teams.length - 1) {
		foreach(j ; i + 1 .. teams.length) {
			Team [2] r = getPoolResults([teams[i].name, teams[j].name]);
			teams[i].goalFor += r[0].score; teams[i].goalAgainst += r[1].score;
			teams[j].goalFor += r[1].score; teams[j].goalAgainst += r[0].score;
			if (r[0].score < 0) continue;
			else if (r[0].score > r[1].score) {
				teams[i].w ++;
				teams[j].l ++;
			} else if (r[0].score == r[1].score) {
				teams[i].d ++;
				teams[j].d ++;
			} else if (r[0].score < r[1].score) {
				teams[i].l ++;
				teams[j].w ++;			
			}
		}
	}

	foreach(i ; 0 .. teams.length - 1) {
		auto k = i + 1;
		foreach(j ; k .. teams.length) {
			if (teams[j] > teams[k]) k = j;			
		}
		if (teams[k] > teams[i]) { 
			TeamEx tmp = teams[i];
			teams[i] = teams[k];
			teams[k] = tmp;
		}
	}
	
	writeln("                  équipe point,    G,    N,    P,   pour, contre,   diff");   
	foreach(t ; teams) t.print();
}

/**
 * Compute a Poisson distribution for the first 10 slot given its expectancy m 
 * It is common to use this  distribution to guess the number of goals in soccer/football
 * see for examples:
 *   https://dashee87.github.io/football/python/predicting-football-results-with-statistical-modelling/
 *   https://exprysm.com/insights/methodology/dixon-coles-model.html
 *   etc.
 * Params: m the number of expected goals
 *         p the probalilty of each goals between 0 to 9 & >= 10.
 */
void poisson(const double m, out double [11] p) {
	p[0] = exp(-m);
	p[10] = 1.0 - p[0];
	foreach (i; 1 .. 10) {
		p[i] = p[i - 1] * m / i;
		p[10] -= p[i];
	}
}	

/**
 * struct proba to compute goal probability of a match
 */
struct Proba {
	string [2] names;
	double w, d, l;
	double [11][2] p;
	Random rnd;
	
	
	this(const string [2] n) {
		names = n;
		Team [2] t = matchExpected(names);
		poisson(t[0].score, p[0]);	
		poisson(t[1].score, p[1]);
		
		
		w = d = l = 0.0;		
		foreach(i; 0 .. 11)
		foreach(j; 0 .. 11) {
			double q = p[0][i] * p[1][j];
			if (i > j) w += q;
			else if (i == j) d += q;
			else l += q;
		}

		rnd = Random(unpredictableSeed);
	}
	
	/** print the probability */
	void print(bool verbose = false) {
		Team [2] t = matchExpected(names);
		
		writeln();
		writeMatch(t); writeln(": ");
		writefln("%s = %.1f%% ; nul = %.1f%%; %s = %.1f%%", t[0].name, w * 100.0, d * 100.0, t[1].name, l * 100.0);
//		writefln("%s; %.1f%%", t[0].name, (w + d / 2) * 100.0);
//		writefln("%s; %.1f%%", t[1].name, (l + d / 2) * 100.0);
		if (verbose) {
			foreach(j; 0 .. 11) write(j, "; ");
			writeln();
			write(t[0].name); foreach(i; 0 .. 11) writef("%.1f%%; ", 100.0 * p[0][i]);
			writeln();
			write(t[1].name); foreach(i; 0 .. 11) writef("%.1f%%; ", 100.0 * p[1][i]);
			writeln();
			
			write("a/b; ");
			foreach(i; 0 .. 11) write(i, "; ");
			writeln();
			foreach(i; 0 .. 11) {
				write(i, "; ");
				foreach(j; 0 .. 11) writef("%.1f%%; ", 100.0 * p[0][i] * p[1][j]);
				writeln();
			}
			writeln();
		}
	}
}

/**
 * firstRound results (round of 32)
 * Params: teams output the 32 qualified teams with their expected chance of winning
 *         verbose print the expected result and the % of chance ot pass this round
 */
void first_round(out Team [32] teams, bool verbose = false) {
	foreach (i; 0 .. 16) {
		Proba p = Proba([FINAL_TEAMS[i * 2], FINAL_TEAMS[i * 2 + 1]]);
		if (isEliminated(p.names[0])) {
			p.l = 1.0; p.d = p.w = 0.0;
		} else if (isEliminated(p.names[1])) {
			p.w = 1.0; p.d = p.l = 0.0;
		} 
		Team [2] t = [ { p.names[0], p.w + p.d / 2.0 }, { p.names[1], p.l + p.d / 2.0 } ]; 		
		if (verbose) {
			Team [2] m = matchExpected(p.names);
			writeMatch(m);
			writePercentage(t);
		}
		teams[i * 2] = t[0];
		teams[i * 2 + 1] = t[1];
	}
}

/** a Glbal variable to compute the result with (TRUE) or without (FALSE) the eliminated teams */
bool KEEP_ELIMINATED = false;

/**
 * Check if a team has been eliminated
 * Params: name name of the team.
 * return true if the team has been eliminated or false otherwise, exept if KEEP_ELIMINATED is set to true,
 * in this case always sreturn false.
 * 
 */
bool isEliminated(string name) {
	if (KEEP_ELIMINATED) return false;
	foreach(e; ELIMINATED) if (name == e) return true;
	return false;
}

/**
 * Check if a team has been eliminated
 * Params: team to check.
 * return true if the team has been eliminated or false otherwise, exept if KEEP_ELIMINATED is set to true,
 * in this case always sreturn false.
 */
bool isEliminated(Team team) {
	return isEliminated(team.name);
}

/**
 * Recursively compute the expected results of a round
 * Params output the 32 teams of the round of 32
 *        nTeams the number of teams qualified after this round (eg 16 after the round of 32, or 1 after the final)
 *        verbose if true write the results
 */
void round(out Team[32] teams, size_t nTeams, bool verbose = false) {
	Team [32] previousTeams;
	size_t n = 32 / nTeams;
	
	if (nTeams == 16) {
		first_round(teams);
		return;			
	} else {
		round(previousTeams, nTeams * 2);
	}		
	
	
	foreach (i; 0 .. 32) {
		teams[i].name = FINAL_TEAMS[i];
		teams[i].score = 0.0;
	}
	
	foreach (i; 0 .. nTeams) {
		foreach (j_i; 0 .. n / 2)
		foreach (k_i; 0 .. n / 2) {
			size_t j = i * n + j_i, k = i * n + n / 2 + k_i;
			Proba p = Proba([ teams[j].name, teams[k].name ]);
			if (isEliminated(p.names[0])) {
				if (isEliminated(p.names[1])) {
					p.w = p.d = p.l = 0.0;
				} else {
					p.l = 1.0; p.d = p.w = 0.0;
				}
			} else if (isEliminated(p.names[1])) {
				p.w = 1.0; p.d = p.l = 0.0;
			} 
			Team [2] t = [ { p.names[0], p.w + p.d / 2.0 }, { p.names[1], p.l + p.d / 2.0 } ]; 
			if (verbose) {
				Team [2] m = matchExpected(p.names);
				writeMatch(m);
				writePercentage(t);
				Team [2] prev = [previousTeams[j], previousTeams[k]];
			}			
			teams[j].score += t[0].score * previousTeams[j].score * previousTeams[k].score;
			teams[k].score += t[1].score * previousTeams[k].score * previousTeams[j].score;;
		}
	}
}

/** 
 write a sorted array of teams
 Params: teams The list of teams
*/
void writeTeams(Team [] teams) {
	teams.sort!("a > b")();
	foreach (t; teams) if (!isEliminated(t)) writefln("%s; %.1f%%", t.name, t.score * 100.0);
}

/** the main function */
void main(string [] args) {
	bool showProba, showElo, showPool, verbose;
	
	auto answer = getopt(args, "proba", "Show winning probability", &showProba,
	"elo|e", "Show Elo for each team", &showElo,
	"pool|p", "Show pool results", &showPool,
	"keepall|k", "Keep all teams from round of 32", &KEEP_ELIMINATED,
	"verbose|v", "Be more vernbose", &verbose);
		
	if (answer.helpWanted) {
		defaultGetoptPrinter("Some information about the program.", answer.options);
		return;
	}
	
	if (showElo) writeEloScore();
	else if (showProba) writeProba();
	else if (showPool) {
		writeln("Matchs joués:");
		writeln("============");
		foreach (r; POOL_RESULTS) {			
			string [2] done = [r[0].name, r[1].name];
			Proba p = Proba(done);
			writeln();
			write("Prédiction: ");
			p.print();
			write("Réalisation: ");
			writeMatch(r);
			writeln();
		}
		
		foreach(pool; POOLS) {			
			writeln("Poule ", pool.pool);
			writeln("===============");
			pool.writePool();
			writeln();
		}		
	} else {		
		writeln();
		writeln("==================================================");
		writeln();
		
		writeln("chance d'atteindre les 8èmes de finale");
		writeln("======================================");
		Team [32] teams;
		first_round(teams, verbose);
		writeTeams(teams);
		writeln("==================================================");
		writeln();

		writeln("chance d'atteindre les quarts de finale");
		writeln("=======================================");
		round(teams, 8, verbose);		
		writeTeams(teams);
		writeln("==================================================");
		writeln();

		writeln("chance d'atteindre les demis finale");
		writeln("===================================");
		round(teams, 4, verbose);		
		writeTeams(teams);
		writeln("==================================================");
		writeln();

		writeln("chance d'atteindre la finale");
		writeln("============================");
		round(teams, 2, verbose);
		writeTeams(teams);
		writeln("==================================================");
		writeln();

		writeln("chance de remporter la coupe du monde 2026");
		writeln("==========================================");
		round(teams, 1, verbose);
		writeTeams(teams);
		writeln("==================================================");
		writeln();
	}
}

