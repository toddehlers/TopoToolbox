function [] = profile51(app)

% profile51.m is the core stream profile analysis code. It works in
% concert with sa_analysis51.m, sa_regress51.m, movavg51.m, usgscontour.m,
% stepremover.m, answer_yn.m, slopes.m, closeto.m, closeto_allvalues.m,
%
% USAGE:
%       chandata = profile51('filename','arcmap_directory','matlab_directory','exist_cd');
%           exist_cd is a flag that indicates whether a new channel should
%           be extracted, or whether one intends to re-process
%           previously-extracted data
% INPUT:
%       'filename' is the part of the dem or acc file that does NOT contain -accm or -demm.
%           Because filename and directory_name are strings they MUST be written within single quotes.
%           It loads files exported as ASCII from ARC, headers trimmed, and saved as .mat files.
%           (these files are the masked dem and flowaccumulation matrices.
%           Make these files manually, or use arcdemtxt2matlab.m).
%           filenameaccm.mat and filenamedemm.mat are loaded from the 'matlab_directory'.
%           The files must contain, respectively, variables named "accum" and "dem".
%                                           OR:
%       'filename' is the prefix of an existing chandata file before _chandata.mat.
%       'arcmap_directory' and 'matlab_directory' are strings that give the complete directory (folder) path (see below).
%            Use '.' as shorthand to specify the local matlab directory.
%       NOTE: In addition to these input parameters, files
%       run_parameters.txt and location_ij.txt must exist in
%       'arcmap_directory'.  These files are created by the profile toolbar
%       in ArcGIS.
% OUTPUT:
%   chandata:  10 column matrix of DEM points along channel; columns are:
%        chandata = [dfd' pelev' drainarea' smooth_pelev' ptargi' ptargj' dfm' auto_ks_vals' x_coord' y_coord']
%        dfd = distance from divide
%        pelev = elevation
%        drainarea = drainage area
%        smooth_pelv = smoothed elevation
%        ptargi = x-coordinate (matrix value)
%        ptargj = y-coordinate (matrix value)
%        dfm = distance from mouth
%        auto_ks_vals = automatically extracted steepness indices along stream
%        x_coord = geographic coordinate (easting)
%        y_coord = geographic coordinate (northing)
%   Various matlab, postscript, and arcmap-loadable files are also interactively saved.
%
% 'arcmap_directory' is the directory where arcmap writes all stream-related text files and shapefiles.
% IT MUST MATCH THE DIRECTORY SPECIFIED IN ARCMAP ("set parameters to sent to matlab" button).
%
% Matlab writes files for input into arcmap into 'arcmap_directory' (e.g., name_stream.txt, section#.txt).
% 'mat_workdir' is the directory where new matlab files are saved.

% To turn on and off various interactive flags, search through profile51.m (and sa_analysis and sa_regress) to find "interactive parameter",
% and then comment out the question line and uncomment the appropriately-set
% value.

% Commented OUT: EDITED to name stream text files as name_stream.txt, to
% work with 10-27-07 version of profiler.dll (not implemented at GSA Short Course)

% set global varible (tribsection).  This is used to number the
% files associated with the trib sections, which are read in Arcview
global TRIBSECTION

% set tribsection
TRIBSECTION = 1;

%flag to import geographic coordinates, rather than matlab indices:
use_geographic_coords=1;

exist_cd = 'n';

if exist_cd=='y',
    disp('Processing PREVIOUS chandata.')
elseif exist_cd=='n',
    disp('Processing NEW chandata.')
else
    disp('Error--invalid entry for exist_cd, must be y or n.  Exiting')
    return
end

%
% *************************************************************************
% Load Data Loop: Dem, Accum for exist_cd = 'n' (no existing chandata),
% Chandata for exist_cd = 'y'
% *************************************************************************
%

arc_workdir = app.profiler_config(1).dem_path
mat_workdir = app.profiler_config(1).dem_path

fprintf('arc_workdir: %s\n', arc_workdir);
fprintf('mat_workdir: %s\n', mat_workdir);

dem = app.DEM.Z;
accum = app.FA.Z;

cellsize = app.profiler_config(1).run_parameter(1);
theta_ref = app.profiler_config(1).run_parameter(2);
rmspike = app.profiler_config(1).run_parameter(3);
no_step = app.profiler_config(1).run_parameter(4);
smooth_prof = app.profiler_config(1).run_parameter(5);
wind = app.profiler_config(1).run_parameter(6);
cont_intv = app.profiler_config(1).run_parameter(7);
ks_window = app.profiler_config(1).run_parameter(8);
Pix_Ran_Dnst = app.profiler_config(1).run_parameter(9);
MinAccum2start = app.profiler_config(1).run_parameter(10);
gridsize = size(accum);

movernset = -1 * theta_ref;
%gridsize used to test if targi,j stepping off grid

% Set cellsize for analysis
pix = round(10 * cellsize) / 10;
diag = round(10 * (sqrt((pix^2) + (pix^2)))) / 10;
ar = round(pix^2);

% TODO: check if these values are corret.
% easting = app.DEM.refmat(3,1);
% northing = app.DEM.refmat(3,2);

% easting = app.DEM.georef.BoundingBox(2,:)
% northing = app.DEM.georef.BoundingBox(1,:)

sizex = app.DEM.size(2)
sizey = app.DEM.size(1)

xmin = app.DEM.refmat(3,1)
xmax = xmin + (cellsize * sizex)

ymin = app.DEM.refmat(3,2)
ymax = ymin + (cellsize * sizey)

easting = [ymin, ymax]
northing = [xmin, xmax]

% import format: [row column easting northing  name]
% note: atargx = northing (rows), atargy = easting (columns)

num_of_reach_obj = numel(app.profiler_config(1).reach_x);
% app.objects.REACHobj.data{1,i}
% app.objects.REACHobj.data{1,1}.x(1)
% app.objects.REACHobj.data{1,1}.y(1)

for i = 1:num_of_reach_obj
  atargiall(i) = app.profiler_config(1).reach_y(i);
  atargjall(i) = app.profiler_config(1).reach_x(i);
  atargyall(i) = app.profiler_config(1).reach_cy(i);
  atargxall(i) = app.profiler_config(1).reach_cx(i);
  nameall(i) = num2str(i);
end


numchanpts = size(atargiall, 1);


if exist_cd == 'y'
    %
    % Else load existing chandata file; name = fname (for uniform input
    % convenience)
    %
    try
        eval(['load ',mat_workdir,fname,'_chandata;']);
    catch
        disp(sprintf('attempt to load chandata file %s failed!',[mat_workdir,fname,'_chandata.mat;']));
        chan_fname = input('Enter correct chandata filename:  ','s');
        try
            eval(['load ',mat_workdir,chan_fname]);
        catch
            disp(sprintf('Attempt to load chandata file %s failed again, exiting.',[mat_workdir,chan_fname]));
            return
        end
    end
    name = fname;

    pix = round(10*cellsize)/10;
    %
end
%
% *************************************************************************
% End Load Data Loop
% *************************************************************************
%


%loop to load ALL points in location_ij.txt, FIRST TIME!  after first time, it can be re-read inside loop, see below.
bigloopnum=1;

answer1 = 1;
while answer1,
    clear pdist paccum pelev drainarea targi targj ptargi ptargj dfm dfd p_x p_y
    %
    TRIBSECTION = 1;
    %
    % *************************************************************************
    % Create Chandata Loop for default, exist_cd = 'n' (no existing chandata)
    % *************************************************************************
    %
    if exist_cd == 'n'
        %
        disp('Computer is creating channel profile downstream of the point selected in ArcMap')

        if bigloopnum > numchanpts,   %case to reread location_ij.txt
            bigloopnum=1;
        end
        atargi=round(atargiall(bigloopnum));
        atargj=round(atargjall(bigloopnum));
        atargx=atargxall(bigloopnum);
        atargy=atargyall(bigloopnum);
        name=char(nameall(bigloopnum));
        disp(sprintf('Processing stream %s from ArcMap',name));

        min_x = min(northing);
        max_x = max(northing);
        min_y = min(easting);
        max_y = max(easting);

        fprintf('atargx: %f, min(northing): %f, max(northing): %f\n', atargx, min_x, max_x);
        fprintf('atargy: %f, min(easting): %f, max(easting): %f\n', atargy, min_y, max_y);
        fprintf('atargi: %d, atargj: %d\n', atargi, atargj);

        %
        targj=round(atargj);
        targi=round(atargi);

        % First, head DOWNSTREAM some # of steps (stepb)to make sure you are in the channel.
        for steps = 0:Pix_Ran_Dnst
            steps = steps+1;
            try
                patch = accum(targi-1:targi+1,targj-1:targj+1);
            catch
                warning('Error!  Most likely, channel starting point is not located on the DEM.  Aborting script.')
                fprintf('targi: %d, targj: %d\n', targi, targj);
                fprintf('width: %d, height: %d\n', app.FA.size(2), app.FA.size(1));
                fprintf('accum width: %d, accum length: %d\n', size(accum, 2), size(accum, 1));
                return
            end
            [i_dnst,j_dnst] = find(patch==max(max(patch)));
            targi=targi+(i_dnst-2);
            targj=targj+(j_dnst-2);
        end

        % Now, search back UPSTREAM, following the path of largest upstream drainage areas.
        upst_accum_present = accum(targi(1),targj(1));
        while upst_accum_present > MinAccum2start
            patch = accum(targi-1:targi+1,targj-1:targj+1);
            list = sort(reshape(patch,9,1));
            [i_list,j_list] = find(list==upst_accum_present);
            output_val = list(i_list-1, j_list);
            [i_upst,j_upst] = find(patch==output_val(1));
            targi=targi+(i_upst-2);
            targj=targj+(j_upst-2);
            targi=targi(1);
            targj=targj(1);
            upst_accum_present = patch(i_upst(1),j_upst(1));
        end

        % Now work back DOWNSTREAM from the channel head to the outlet.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        true=1;
		step=1;
        distance = [diag pix diag pix 0 pix diag pix diag];
        % Gather data from the first pixel of the channel
		pdist(step)=0;
		paccum(step)=accum(targi,targj);
		pelev(step)=dem(targi,targj);
%         plith(step)=rock(targi,targj);
		ptargi(step)=targi;
		ptargj(step)=targj;

		% Begin the channel extraction while loop:
		while true == 1
			step=step+1;
            patch = accum(targi-1:targi+1,targj-1:targj+1);
            patch(2,2)=0;
            if step>2
                patch(2-(targi-ptargi(step-2)),2-(targj-ptargj(step-2)))=0;
            end
            [list,index] = sort(reshape(patch,9,1));
            dnst_accum = list(9);
            [i_dnst,j_dnst] = find(patch==dnst_accum);
            targi=targi+(i_dnst(1)-2);
            targj=targj+(j_dnst(1)-2);

            % now extract data for this new point
            pdist(step)=distance(index(9));
            paccum(step)=dnst_accum;
            pelev(step)=dem(targi,targj);
%             plith(step)=rock(targi,targj);
			ptargi(step)=targi;
			ptargj(step)=targj;
			p_x(step) = targi;
			p_y(step) = targj;

            % Note: will attempt to step out of bounds and will crash if last
            % point on channel is at edge of dem (i.e., if there is no NODATA
            % buffer)
            if paccum(step) < paccum(step-1)
                true = 0;
            elseif targi >= gridsize(1)
                true = 0;
            elseif targj >= gridsize(2)
                true = 0;
            elseif targi <=1
                true = 0;
            elseif targj <=1
                true = 0;
            end
    end

        % Calculate cumulative distance from divide and convert to distance from the mouth.
        % Flip pelev, dfd  and paccum vectors.
        dfd = cumsum (pdist);
		pelev = fliplr(pelev);
%         plith = fliplr(plith);
		paccum = fliplr(paccum);
		dfd = fliplr(dfd);
		ptargi = fliplr(ptargi);
		ptargj = fliplr(ptargj);
		p_x = fliplr(p_x);
		p_y = fliplr(p_y);
		dfm = max(dfd)-dfd;
		% Convert drainage area from pix to m^2.  Create dummy data for smooth_pelev
		drainarea = (paccum.*ar);
		smooth_pelev = zeros(1,max(size(pelev)));
        auto_ks_vals = zeros(1,max(size(pelev)));
		x_coord = zeros(1,max(size(pelev)));
		y_coord = zeros(1,max(size(pelev)));


        % make the chandata matrix
        chandata = [dfd' pelev' drainarea' smooth_pelev' ptargi' ptargj' dfm' auto_ks_vals' x_coord' y_coord'];
    end
    %
    % *************************************************************************
    % END Create Chandata Loop for default, exist_cd = 'n' (no existing chandata)
    % *************************************************************************
    %
    % *************************************************************************
    % Chandata now loaded for either option, begin analysis
    % *************************************************************************
    %


    % reset variables to ensure all are in the same row vector format.
    dfd = chandata(:,1)';
    pelev = chandata(:,2)';
    drainarea = chandata(:,3)';
    smooth_pelev = chandata(:,4)';
    ptargi = chandata(:,5)';
    ptargj = chandata(:,6)';
    p_x = ptargi;
    p_y = ptargj;
    dfm = chandata(:,7)';
    % *************************************************************************
    % Loop to perform analysis starts here
    % *********************************************************************
    %

    if rmspike,
        temp_elev = fliplr(pelev);
        q = length(temp_elev)-1;
        for i = 1:q
            if temp_elev(i+1) > temp_elev(i)
                temp_elev(i+1) = temp_elev(i);
            end
        end
        new_pelev = fliplr(temp_elev);
    else
        new_pelev = pelev;
    end

    if no_step,
        smooth_pelev = new_pelev;
        chandata(:,4) = smooth_pelev';
        wind = 0;
    else
        %only allow smoothing if step remover will not be used:  smooth raw
        %dem data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if smooth_prof,
            [smooth_pelev] = movavg51(new_pelev,pix,wind);
            % replace with option movavg51a to break into segments, avoid
            % smoothing across tributary junctions
            % [smooth_pelev] = movavg51a(new_pelev,drainarea,pix,wind);
            chandata(:,4) = smooth_pelev';
        else
            smooth_pelev = new_pelev;
            chandata(:,4) = smooth_pelev';
            wind = 0; %no smoothing done
        end
    end
    %
    % end spike removal / step removal / smoothing routine



    % Second: call function sa_analysis to run slope-area analysis and
    % knickpoint picking routine
    %

[ida,islope,lbarea,lbslope,chandata,ans2] = sa_analysis51(chandata,movernset,name,arc_workdir,mat_workdir,rmspike,wind,no_step,ks_window,cont_intv);


    % write text file of necessary chandata out for Arcview.  This will be loaded into table for creating the stream data.
    % toGisData  = [dfd' pelev' drainarea' smooth_pelev' p_x' p_y']; %(the old format)
    % WK: 2016.06.08, calculate chi and save it together with the chandata values.

    % A(x): (drain)area, chandata[:, 3]
    % x: dfm (distance from mouth), chandata[:, 7]
    % A0 = 1
    % movernset = -1 * theta_ref;

    da = chandata(:, 3)';
    stop = length(dfm);
    chi(1)=0;
    for i = 2:stop
      chi(i) = chi(i-1) + ((da(i).^(movernset) + da(i-1).^(movernset)) ./ 2) .* (dfm(i) - dfm(i-1));
    end

    toGisData  = [drainarea' chandata(:,8) p_x' p_y' chandata(:,9) chandata(:,10) chi'];
    %
    [v,d]=version;
    if str2num(v(1))==6
        %dlmwrite([arc_workdir,name,'.txt'], toGisData,' ');
        dlmwrite([arc_workdir,name,'_stream.txt'], toGisData,' ');
    else
        %dlmwrite([arc_workdir,name,'.txt'],toGisData,'delimiter',' ','precision','%1.14g');
        dlmwrite([arc_workdir,name,'_stream.txt'],toGisData,'delimiter',' ','precision','%1.14g');
    end

    % WK: Export shape file
    % auto_ks_vals: steepness information, inside chandata[:, 8]
    % x = chandata[:, 9], y = chandata[:, 10]

    s(1:length(auto_ks_vals)) = struct('ksn', 0.0, 'chi', 0.0, 'Geometry', 'Point', 'X', 0.0, 'Y', 0.0);

    for i = 1:length(auto_ks_vals)
      s(i).ksn = double(chandata(i, 8));
      s(i).chi = chi(i);
      s(i).X = double(p_x(i));
      s(i).Y = double(p_y(i));
    end

    shapewrite(s, [arc_workdir, name, '_auto_ks_vals.shp']);

    % WK: 2016.06.30, append chi values to end of chandata matrix
    chandata = [chandata chi'];

    % *********************************************************************
    % BEGIN FINAL DATA/FIGURE-SAVING ROUTINE
    % *********************************************************************

%%%%%%%%%%%INTERACTIVE PARAMETER--Comment out interactive, uncomment set value, if desired
    disp('Set the axis limits of the first two plots:')
    ans3 = answer_yn('Change the axis limits for fig 2, subplots 1 and 2?');
%    ans3 = 0;    %for no
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ans3,
        if ~isempty(who('min_elev')) & ~isempty(who('max_elev')) & ~isempty(who('max_length')),
            ans4=answer_yn('Use previous bounds?');
            if ans4,
            else
                min_elev=input('Enter minimum elevation (m):  ');
                max_elev=input('Enter maximum elevation (m):  ');
                max_length=input('Enter max channel length (km):  ');
            end
        else
            min_elev=input('Enter minimum elevation (m):   ');
            max_elev=input('Enter maximum elevation (m):   ');
            max_length=input('Enter max channel length (km):    ');
        end

        figure (2)
        subplot(3,1,1)
        try
            axis([0 max_length min_elev max_elev])
        catch
            disp('Error rescaling axis, probably from bad user input on min and max values.')
            disp('One more chance to enter reasonable values:')
            min_elev=input('Enter minimum elevation (m):   ');
            max_elev=input('Enter maximum elevation (m):   ');
            max_length=input('Enter max channel length (km):    ');
            try
                axis([0 max_length min_elev max_elev])
            catch
                disp('Error rescaling axis, probably from bad user input on mins and maxes.  Axes unchanged.')
            end
        end
        subplot(3,1,2)
        w2=axis;
        try
            axis([ 0 max_length w2(3) w2(4)])
        catch
            disp('Error rescaling axis, probably from bad user input on mins and maxes.  Axes unchanged.')
        end

        figure (3)
        subplot(3,1,1)
        w2=axis;
        try
            axis([0 max_length w2(3) w2(4)])
        catch
            disp('Error rescaling axis, probably from bad user input on mins and maxes.  Axes unchanged.')
        end
        subplot(3,1,2)
        w2=axis;
        try
            axis([0 max_length w2(3) w2(4)])
        catch
            disp('Error rescaling axis, probably from bad user input on mins and maxes.  Axes unchanged.')
        end

        subplot(3,1,3)
        w2=axis;
        try
            axis([0 max_length w2(3) w2(4)])
        catch
            disp('Error rescaling axis, probably from bad user input on mins and maxes.  Axes unchanged.')
        end
    end

    %
    % Different save filename options depending on whether a pre-existing
    % chandata file is being reprocessed
    %
    if exist_cd == 'n'
%        t5 = answer_yn('Save this long profile (chandata.mat) and print figures?');
        t5 = ans2;
        if t5,
            sa_data = [ida' islope'];
            lb_sa_data = [lbarea' lbslope'];
            eval ([' save ',mat_workdir,name,'_chandata.mat chandata -MAT'])
            %        eval ([' save ',mat_workdir,name,'_chandata_ns.mat chandata_ns -MAT'])
            eval ([' save ',mat_workdir,name,'_sa_data.mat sa_data -MAT'])
            eval ([' save ',mat_workdir,name,'_lb_sa_data.mat lb_sa_data -MAT'])
        end
%        t3 = answer_yn('Print matlab figures (2 and 3) to file?');
        t3=ans2;
        if t3,
            figure(2)
            % arc_workdir,name,'.txt'  saveas(gcf,'pred_prey.fig')
            eval ([' print -depsc ',mat_workdir,name,'.eps'])
            figname = [arc_workdir name '.jpg'];
            saveas (gcf,figname)
            figure(3)
            eval ([' print -depsc ',mat_workdir,name,'_f3.eps'])
            figname = [arc_workdir name '_f3.jpg'];
            saveas (gcf,figname)
        end

        disp('You MUST return to ArcMap and import data using the "add stream shapefile"')
        disp('and "create knickpoint shapefile" buttons.  Otherwise NO SHAPEFILES will be saved.')
        bigloopnum=bigloopnum+1;
        if bigloopnum <= numchanpts,    %case where there are more rows in location_ij.txt to read as channel heads
            disp('After importing data to ArcMap, the next point channel starting point previously chosen will be used (from location_ij.txt).')
%             answer1 = answer_yn(sprintf('Continue with the next starting point, %s, previously chosen from ArcMap? (y to continue, n to quit)',nameall(bigloopnum,:)));
            answer1 = answer_yn(sprintf('Continue with the next starting point, %s, previously chosen from ArcMap? (y to continue, n to quit)',char(nameall(bigloopnum))));
        else
            disp('No more points chosen for processing!')
            disp('After importing data, you MUST select another tributary starting point ("send a point to matlab" button) in ArcMap.')
            disp('Otherwise, previous point will be used.')
            answer1 = answer_yn('Are you ready to grab another starting point from ArcMap? (y to continue, n to quit)');
        end

    else if exist_cd == 'y'

            suffix = '';
            t5 = answer_yn('Save this processed long profile matlab data?');
            if t5,
                suffix = input(sprintf('Enter optional suffix (*) for naming %s_*_sa_data, %s_*_lb_sa_data and %s_*_chandata :  ',name,name,name),'s');
                sa_data = [ida' islope'];
                lb_sa_data = [lbarea' lbslope'];
                eval ([' save ',mat_workdir,name,'_',suffix,'_chandata.mat chandata -MAT'])
                %%right now saving doesn't save all of the no-step or interpolated chandata points; only saves the slope and area at these points.
                %        eval ([' save ',mat_workdir,name,'_chandata_ns.mat chandata_ns -MAT'])
                %sa_data is 2 columns, 1st col drainage area, 2nd column slope, only at the chosen (step removed or interpolated) subset of points.
                eval ([' save ',mat_workdir,name,'_',suffix,'_sa_data.mat sa_data -MAT'])
                %lb is for log-binned, 2 col drainage area and slope (as shown in slope-area plot, fig2 plot3).
                eval ([' save ',mat_workdir,name,'_',suffix,'_lb_sa_data.mat lb_sa_data -MAT'])
            end
            t3 = answer_yn('Print matlab figures (2 and 3) to file?');
            if t3,
                figure(2)
                eval ([' print -depsc ',mat_workdir,name,'_',suffix,'_fig2.ps'])
                figure(3)
                eval ([' print -depsc ',mat_workdir,name,'_',suffix,'_fig3.ps'])
            end
            %
            % no repeat cycle if reprocessing specified chandata file
            %
            answer1 = 0;

        end
        %
        % End Save Options Loop
        %
    end
    %
    % End While Loop for repeat analysis if answer1 = 1, END profile3.m
    %
end
