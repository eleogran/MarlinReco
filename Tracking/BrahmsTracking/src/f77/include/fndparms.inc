*  
* $Id: fndparms.inc,v 1.3 2006-02-08 14:58:57 owendt Exp $
*  
* $Log: not supported by cvs2svn $
* Revision 1.2  2006/02/07 10:54:08  owendt
* changed NTPCOMX from 50000 to 150000,
* 	NTPMAX  from 30000 to  90000
* and     MAXCND  from 30000 to  60000 to ensure stable tracking with Mokka 5.04
*
* Revision 1.1.1.1  2005/07/11 15:15:48  aplin
* Initial version
*
* Revision 1.1.1.1  2005/06/18 10:05:35  gaede
* Initial local version
*
* Revision 1.1  2005/06/13 16:14:29  aplin
* *** empty log message ***
*
* Revision 1.1.1.1  2003/05/23 13:17:48  hvogt
* Brahms V308
*
*  
      INTEGER NTPMAX,MAXCND,NTPCOMX
*      PARAMETER(NTPMAX=30000,MAXCND=30000,NTPCOMX=50000)
      PARAMETER(NTPMAX=200000,MAXCND=100000,NTPCOMX=500000)


