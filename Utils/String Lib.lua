if getgenv().Mawborn.Library.String then
    return
end

local String = {};

function String.valueOf(Source)
	return tostring(Source);
end

function String.isEmpty(Source)
	return Source == '';
end

function String.toLowerCase(Source)
	return string.lower(Source);
end

function String.toUpperCase(Source)
	return string.upper(Source);
end

function String.startsWith(Source, Char)
	return string.sub(Source, 1, 1) == Char;
end

function String.sentanceCase(Source)
	return string.upper(string.sub(Source, 1, 1)) .. string.sub(Source, 2);
end

function String.contains(Source, Search)
	return string.find(Source, Search, 1, true)
end

function String.trim(Source)
	return string.match(Source, '^%s*(.-)%s*$');
end

function String.join(Char, Source)
	if type(Source) ~= 'table' then
		error('Invalid type on argument 2, must be a table')
	end

	return table.concat(Source, Char)
end

function String.ulength(Source)
	return utf8.len(Source);
end

function String.length(Source)
	return string.len(Source);
end

function String.charAt(Source, Index)
	return string.sub(Source, Index, Index);
end

function String.matches(Source1, Source2)
	return Source1 == Source2
end

function String.replace(Source, Search, Replace)
	return (string.gsub(Source, Search, Replace, 1));
end

return String;
