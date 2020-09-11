function parts = split_str(splitstr, str)
% 
% This function was found on the internet at http://www.paulkiddie.com/2009/01/split_str-split-a-string-based-on-an-array-of-character-delimiters-in-matlab/
% on 15th Feb 2010. I believe it was written by Paul Kiddie. Thanks, Paul, for the useful code. 
%
%
%split_str Split a string based upon an array of character delimiters
%
%   split_str(splitstr, str) splits the string STR at every occurrence
%   of an array of characters SPLITSTR and returns the result as a cell
%   array of strings.
%
%   usage: split_str(['_';','],'hi,there_how,you_doin?')
%
%   ans =
%
%    'hi'    'there'    'how'    'you'    'doin?'
%
   nargsin = nargin;
   error(nargchk(2, 2, nargsin));

   splitlen = 1;  %char's of length 1
   parts = {};

   k=[];           %empty array holding indexes of where to split
   last_split = 1; %index of last split

      for x=1:length(splitstr)
          k = [k strfind(str, splitstr(x))];     %combines all the found indexes
      end

      k = sort(k);   %sorts out indexes

      if isempty(k)
         parts{end+1} = str;
         return;
      end

      for x=1:length(k)
          parts{end+1} = str(last_split : k(x)-1);

          last_split = k(x)+1;
      end

      %now add the final string to the result
      parts{end+1} = str(last_split : length(str));
end
