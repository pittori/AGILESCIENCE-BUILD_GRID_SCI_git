#! /usr/bin/ruby
#0) filter 
#1) maplist
######### Optional parameters
# FILE management
#2) startlist - file name of the starting list (in alike multi format, default none)
#3) scanlist   - file name of the scan list (default none, if none, generate a list with spot finder)
#4) outfile   - output file prefix 
# ALIKE parameters -----------------------
#5) ranal     - radius of analysis (default 10)
#6) galmode       - gal mode (optional, default 1)
#7) isomode       - iso mode (optional, default 1)
#8) ulcl      - upper limit confidence level (default 2)
#9) loccl     - source location contour confidence level (default 95 (%)confidence level) Vales: 99, 95, 68, 50
# ITERATIVE parametes ---------------------
#5) scanitmax   - scan iterations (optional, default 20)
#6) scantsthr   - sqrt(TS) threshold (optional, default 2) - esci dalla procedura iterativa se non hai trovato nessuna detection maggiore di questo TS
#7) scandistthr - min dist thresholds (optional, default 0.5) - non fare alike se la nuova source e' piu' vicina
#8) fixdistthr  - fixdistance thresholds (optional, default 2) - se le sorgenti sono più lontane di fixdistthr allora metti fixflag=0
#9) minsourcesqrts - min sqrt(TS) to make the second loop of the DoFit (optional, default 2)
#10) fixflagstep2 - fix flag for second step of iterative (optional, default 3)
# SCAN LIST GENERATION (if scan list name is none)
#12) binstep     - bin step for generation of list of points to analyze (optional, default 2) - if param 3 is != none don't use it
#14) rextract    - radius of scan (default mapsize.to_i / 2.0 - ranal.to_i;)
#15) lcenter     - l center of analysis (default, the center of the map)
#16) bcenter     - b center of analysis (default, the center of the map)
#10) fixflagscan - fixflag of scan list (defaul 1)
#11) scanlistdistthr - distance max (last column of the multi file

#Formato della lista (esclusi #)
# !  flux     lii   bii  index fix minTS  label
# 352.9e-8  195.06  4.31 1.66  2   3.0   Geminga 2.0
# 226.2e-8  184.53 -5.84 2.19  2   3.0   Crab	 0.0
# 51.4e-8   189.00  3.05 2.01  2   3.0   IC443   0.0


load ENV["AGILE"] + "/scripts/conf.rb"
datautils = DataUtils.new

if ARGV[0].to_s == "help" || ARGV[0] == nil
	system("head -34 " + $0 );
	exit;
end

filter = ARGV[0];
maplist = ARGV[1];

cts=""
File.open(maplist).each_line do | line |
	cts = line.split(" ")[0]
end

datautils.readFitsHeader(cts);

binsize = datautils.header["CDELT2"].to_f;
if binsize.to_f < 0
	binsize = -binsize
end
puts "BINSIZE " + binsize.to_s

naxis1 = datautils.header["NAXIS1"].to_f;
mapsize = ((naxis1.to_i-1) * binsize.to_f).to_i
puts "MAPSIZE " + mapsize.to_s

startlist = "none"
scanlist = "none"
outfile = nil

scanitmax = 20;
scantsthr = 2;
scandistthr = 0.5;
fixdistthr = 2;
binstep = 2;

ranal = 10;
galmode = 1;
isomode = 1;
fixflagscan = 1;
fixflagstep2 = 3;
scanlistdistthr = 2.0
minsourcesqrts = 2.0
lcenter = -1
bcenter = -1

ulcl = 2.0;
loccl = 5.9914659;
rextract = mapsize.to_i / 2.0 - ranal.to_i;

for i in 2...1000
	if ARGV[i] == nil
		break;
	else
		keyw = ARGV[i].split("=")[0];
		value = ARGV[i].split("=")[1];
		puts keyw.to_s + " " + value.to_s
		case keyw
			when "startlist"
				startlist = value;
			when "scanlist"
				scanlist = value;
			when "outfile"
				outfile = value;
			when "ranal"
				ranal = value;
			when "galmode"
				galmode = value;
			when "isomode"
				isomode = value;
			when "ulcl"
				ulcl = value;
			when "loccl"
				loccl = value;
			when "fixflagscan"
				fixflagscan = value;
			when "lcenter"
				lcenter = value;
			when "bcenter"
				bcenter = value;
			when "rextract"
				rextract = value;
			when "binstep"
				binstep = value;
			when "scanitmax"
				scanitmax = value;
			when "scantsthr"
				scantsthr = value;
			when "scandistthr"
				scandistthr = value;
			when "fixdistthr"
				fixdistthr = value;
			when "scanlistdistthr"
				scanlistdistthr = value;
			when "minsourcesqrts"
				minsourcesqrts = value;
			when "fixflagstep2"
				fixflagstep2 = value;
			else
				puts "Keyword " + ARGV[i].to_s + " error."
				exit;
		end
	end

end

datautils.readFitsHeader(cts);
if lcenter.to_f == -1
	lcenter = datautils.header["CRVAL1"].to_f;
end
if bcenter.to_f == -1
	bcenter = datautils.header["CRVAL2"].to_f;
end
puts "LCENTER " + lcenter.to_s
puts "BCENTER " + bcenter.to_s


if loccl.to_f == 95
	loccl = 5.99147
end
if loccl.to_f == 99
	loccl = 9.21034
end
if loccl.to_f == 50
	loccl = 1.38629
end
if loccl.to_f == 68
	loccl = 2.29575
end

if startlist.to_s == "none"
	cmd = "touch none"; system(cmd)
end


if outfile == nil
	outfile = maplist.to_s + "_" + startlist.to_s + "_ra" + format("%2d", ranal);
	if gascoeff.to_f != -999
		outfile += "_gal"
		outfile += gascoeff.to_s;
	end
	if iso.to_f != -999
		outfile += "_iso"
		outfile += iso.to_s;
	end
	outfile += ".res";
end

if File.exists?(scanlist) == true
	system("rm " + scanlist.to_s);
end

#selezione della matrix
filterdir = filter;


#selezione della matrix
filterbase = filter.split("_")[0];
datautils.getResponseMatrix(filter);
sarmatrix = datautils.sarmatrix
edpmatrix = datautils.edpmatrix
psdmatrix = datautils.psdmatrix

#generazione della scan list



if scanlist == "none"
	scanlist = outfile.to_s + ".scanlist";
	cmd = ENV["AGILE"] + "/bin/AG_iterativeGenSrcList5 " + cts.to_s + " " + lcenter.to_s + " " + bcenter.to_s + " " + rextract.to_s + " " + binstep.to_s + " 2.1 " + fixflagscan.to_s + " 0.0 " + scanlist.to_s + " " + scanlistdistthr.to_s;
	puts cmd
	system(cmd)
end


#3) conversione della .list
startlistmulti = startlist.to_s 

matrixconf = datautils.getResponseMatrixString(filter);

cmd = ENV["AGILE"] + "/bin/AG_multiterative5 " + maplist.to_s + matrixconf.to_s + " " + scanlist.to_s + " " + scanitmax.to_s + " " + scantsthr.to_s + " " + scandistthr.to_s + " " + fixdistthr.to_s + " " + minsourcesqrts.to_s + " " + ranal.to_s + " " + galmode.to_s + " " + isomode.to_s +  " " + startlistmulti.to_s + " " + outfile.to_s + " " + ulcl.to_s + " " + loccl.to_s + " " + fixflagscan.to_s + " " + fixflagstep2.to_s;
puts cmd
system(cmd)

cmd = "ruby " + ENV["AGILE"] + "/scripts/convertMultiToReg.rb " + outfile.to_s;
puts cmd;
system(cmd);

