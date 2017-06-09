function segs=delaunaynSegs(coords)

%segs=delaunaynSegs(coords)
%
%This program uses N-dimensional delaunay triangulation to determine points
%which are in close proximity. Then, it converts the triangulation into
%segment information, with no duplication. 
%
%INPUTS:    COORDS:     The N-dimensional coordinates of the points, with
%                       each dimension in a column. 
%
%OUTPUTS:   SEGS:       The indices of the points which connect to each
%                       other. Each row represents one connection
%
%Written by Stephen Anthony 04/2009 U. Illinois Urbana-Champaign
%Last modified by Stephen Anthony on 12/02/2009

%Determine the overall size, and dimensionality
[Npoints,dim]=size(coords);

if Npoints>2
    %Use delaunay triangulation to locate nearest neighbors
    warning off MATLAB:delaunayn:DuplicateDataPoints
    tri=delaunayn(coords,{'Qt','Qbb','Qc','Qz'});
    warning on MATLAB:delaunayn:DuplicateDataPoints

    %Presently, we have N-dimensional triangles, where we want segments. Find
    %all possible orderings.
    perms=nchoosek(1:(dim+1),2);

    %Determine the number of potential segments
    N=size(tri,1)*size(perms,1);

    %Find all potential segments, with much duplication
    segs=[reshape(tri(:,perms(:,1)'),N,1) reshape(tri(:,perms(:,2)'),N,1)];

    %Place them in number order
    switchorder=segs(:,1)>segs(:,2);
    segs(switchorder,[1 2])=segs(switchorder,[2 1]);

    %Determine all segments, eliminating duplication
    Stmp=sparse(segs(:,1),segs(:,2),ones(N,1),Npoints,Npoints);
    [p1,p2]=find(Stmp~=0);

    segs=[p1 p2];
elseif Npoints==2
    %Only two points, they must be nearest neighbors
    segs=[1 2];
else
    %Less than two points. Null output.
    segs=zeros(0,2);
end


