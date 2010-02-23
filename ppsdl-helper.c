/**************************************************
 *
 * This is helper program for ppsdl
 * 
 * This program is free software, use at your own
 * risk. For detail, visit
 * http://www.gnu.org/licenses/gpl.html
 *
 * Author: Ronmi Ren <ronmi@rmi.twbbs.org>
 *
 *************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void main()
{
  char s[256];
  char buf[3]={0,0,0};
  char res[256];
  int i,j=0,k;
  char a;
  scanf("%s", s);
  for(i=0;i<strlen(s);i++)
  {
    if(s[i]=='%')
    {
      buf[0]=s[i+1];
      buf[1]=s[i+2];
      i+=2;
      a=(char) strtol(buf, (char **)NULL, 16);
    }
    else a=s[i];
    res[j++]=a;
  }
  res[j]=0;
  printf("%s", res);
}
