#ifndef __REQUIREMENT_HPP
#define __REQUIREMENT_HPP

#define STRLEN 100

int total_frames;
int all_class;
char cname[STRLEN];
struct event
{
	char class_name[STRLEN];
	double *value;
};

#endif