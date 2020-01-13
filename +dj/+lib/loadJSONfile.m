function data = loadJSONfile(jsonFileName)
%     tic
    raw = fileread(jsonFileName);
    data = jsondecode(raw);
    newFields = fieldnames(orderfields(data));
    for i=1:length(newFields) 
        for j=1:length(data.(newFields{i}))
            if isstruct(data.(newFields{i})(j))
                if exist('res','var')
                    res(end + 1) = fixProps(data.(newFields{i})(j), raw);
                else
                    res = fixProps(data.(newFields{i})(j), raw);
                end
                if j == length(data.(newFields{i}))
                    data.(newFields{i}) = res;
                    clear res;
                end
            end            
        end
        newFields{i} = regexprep(regexp(raw, regexprep(newFields{i},'_','.'), 'match', 'once'),'\.[a-zA-Z0-9]','${upper($0(2))}');
    end
    data = cell2struct(struct2cell(orderfields(data)), newFields);
%     toc
end


function data = loadJSONfileold(jsonFileName)
    % jsonFileName -> string
    % data -> Containers.Map
    
    tic
    raw = fileread(jsonFileName);
    data = start(raw);
    data = fixProps(data, raw);
    % data = loadjson(jsonFileName);
    toc
end

function data = fixProps(data, raw)
    newFields = fieldnames(orderfields(data));
    for i=1:length(newFields) 
        for j=1:length(data.(newFields{i}))
            if isstruct(data.(newFields{i})(j))
                if exist('res','var')
                    res(end + 1) = fixProps(data.(newFields{i})(j), raw);
                else
                    res = fixProps(data.(newFields{i})(j), raw);
                end
                if j == length(data.(newFields{i}))
                    data.(newFields{i}) = res;
                    clear res;
                end
            end            
        end
%         [start,last] = regexp(raw, regexprep(newFields{i},'_','.'), 'match', 'once');
        newFields{i} = regexprep(regexp(raw, regexprep(newFields{i},'_','.'), 'match', 'once'),'\.[a-zA-Z0-9]','${upper($0(2))}');
    end
    data = cell2struct(struct2cell(orderfields(data)), newFields);
end

function data = start(raw)
%     raw = strtrim(raw);
    raw = regexprep(raw,'\s','');
    if raw(1) == '{' && raw(end) == '}'
%         data = doObj2(raw);
        data = jsondecode(raw);
%         data = dj.lib.json_decode(raw);
    elseif raw(1) == '[' && raw(end) == ']'
        data = doArray2(raw);
    end
end

function data = doObj2(raw)
    stack_ref = containers.Map( ...
        {'{', '[', '"', 'n', 't', 'f'}, ...
        {'}', ']', '"', 'l', 'e', 'e'});
    stack_count_ref = containers.Map( ...
        {'{', '[', '"', 'n', 't', 'f'}, ...
        {1, 1, 2, 2, 1, 1});
    num_close = {',', '}', ']'};
    
    target_count = [];
    end_chars = {};
    is_char = false;
    close_count = 0;
    curr_stack = [];
%     curr_stack_keys = {};
    key = '';
    value = [];
%     data = containers.Map();
    data = struct();
    
%     raw = strtrim(raw);
    raw = raw(2:end);
    for i = 1:length(raw)
        debug = raw(i);
%         if ~isspace(raw(i))
            if ~is_char && any(strcmp(raw(i), stack_ref.keys))
                curr_stack(end + 1) = i;
                target_count(end + 1) = stack_count_ref(raw(i));
                end_chars{end + 1} = {stack_ref(raw(i))};
            elseif ~is_char && raw(i) >= '0' && raw(i) <= '9' && (raw(i-1) < '0' || raw(i-1) > '9') && ~strcmp(raw(i-1),'.')
                curr_stack(end + 1) = i;
                target_count(end + 1) = 1;
                end_chars{end + 1} = num_close;
            end
            if raw(i) == ':' && isempty(curr_stack)
                key = regexprep(value,'\.[a-zA-Z0-9]','${upper($0(2))}');
    %             curr_stack_keys{end + 1} = value;
            elseif raw(i) == '"'
                is_char = ~is_char;            
            end
            if ~isempty(end_chars) && any(strcmp(raw(i), end_chars{end}))
                close_count = close_count + 1;
            end
    %         if ~isempty(curr_stack) && stack_ref(raw(curr_stack(end))) == raw(i) && i ~= curr_stack(end)
            if ~isempty(end_chars) && close_count == target_count(end)
                if length(end_chars) == 1 || (length(end_chars) == 2 && any(strcmp(raw(i), end_chars{end-1})) && any(strcmp(raw(i), end_chars{end})))
                    if raw(i) == '}' && i ~= length(raw)
                        value = doObj2(raw(curr_stack(1):i));
                    elseif raw(i) == ']'
                        value = doArray2(raw(curr_stack(1):i));
                    elseif raw(i) == '"' && isempty(key)
                        value = raw(curr_stack(1)+1:i-1);
                    else
                        value = readSingle(raw(curr_stack(1):i-1));
                    end
                    if ~isempty(key)
        %                 data(key) = value;
                        data.(key) = value;
                        key = '';
        %                     curr_stack_keys{end} = [];
                        value = [];
                    end
%                     end_chars(end) = [];
%                     curr_stack(end) = [];
%                     target_count(end) = [];
%                     close_count = 0;
%                     end_chars = {};
        %                 curr_stack = [];
                end
                if length(end_chars) > 1 && any(strcmp(raw(i), end_chars{end-1})) && any(strcmp(raw(i), end_chars{end}))
                    end_chars(end) = [];
                    curr_stack(end) = [];
                    target_count(end) = [];
                end
                end_chars(end) = [];
                curr_stack(end) = [];
                target_count(end) = [];
                close_count = 0;
            end
%         end
    end
%     if raw(end) == '}'
%         curr_stack(end) = [];
%     end
    assert(isempty(curr_stack));
%     assert(isempty(curr_stack_keys));
end

function data = doArray2(raw)
    stack_ref = containers.Map( ...
        {'{', '[', '"', 'n', 't', 'f'}, ...
        {'}', ']', '"', 'l', 'e', 'e'});
    stack_count_ref = containers.Map( ...
        {'{', '[', '"', 'n', 't', 'f'}, ...
        {1, 1, 2, 2, 1, 1});
    num_close = {',', '}', ']'};
    
    target_count = [];
    end_chars = {};
    is_char = false;
    close_count = 0;
    curr_stack = [];
%     curr_stack_keys = {};
%     key = '';
%     value = [];
%     data = containers.Map();
%     data = [];
    
%     raw = strtrim(raw);
    raw = raw(2:end);
    for i = 1:length(raw)
        debug = raw(i);
%         if ~isspace(raw(i))
            if ~is_char && any(strcmp(raw(i), stack_ref.keys))
                curr_stack(end + 1) = i;
                target_count(end + 1) = stack_count_ref(raw(i));
                end_chars{end + 1} = {stack_ref(raw(i))};
            elseif ~is_char && raw(i) >= '0' && raw(i) <= '9' && ( i == 1 || ((raw(i-1) < '0' || raw(i-1) > '9') && ~strcmp(raw(i-1),'.')))
                curr_stack(end + 1) = i;
                target_count(end + 1) = 1;
                end_chars{end + 1} = num_close;
            end
            if raw(i) == '"'
                is_char = ~is_char;            
            end
            if ~isempty(end_chars) && any(strcmp(raw(i), end_chars{end}))
                close_count = close_count + 1;
            end
    %         if ~isempty(curr_stack) && stack_ref(raw(curr_stack(end))) == raw(i) && i ~= curr_stack(end)
            if ~isempty(end_chars) && close_count == target_count(end)
                if length(end_chars) == 1 || (length(end_chars) == 2 && any(strcmp(raw(i), end_chars{end-1})) && any(strcmp(raw(i), end_chars{end})) && raw(curr_stack(end))~=raw(curr_stack(end-1)))
                    if raw(i) == '}' && i ~= length(raw)
                        value = doObj2(raw(curr_stack(1):i));
                    elseif raw(i) == ']' && i ~= length(raw)
                        value = doArray2(raw(curr_stack(1):i));
                    elseif raw(i) == '"'
                        value = raw(curr_stack(1)+1:i-1);
                    else
                        value = readSingle(raw(curr_stack(1):i-1));
                    end
                    if exist('data','var')
                        data(end + 1) = value;
                    else
                        data = value;
                    end
%                     if ~isempty(key)
%         %                 data(key) = value;
%                         data.(key) = value;
%                         key = '';
%         %                     curr_stack_keys{end} = [];
%                         value = [];
%                     end
%                     close_count = 0;
%                     end_chars = {};
        %                 curr_stack = [];
                end
                if length(end_chars) > 1 && any(strcmp(raw(i), end_chars{end-1})) && any(strcmp(raw(i), end_chars{end}))
                    end_chars(end) = [];
                    curr_stack(end) = [];
                    target_count(end) = [];
                end
                end_chars(end) = [];
                curr_stack(end) = [];
                target_count(end) = [];
                close_count = 0;
            end
%         end
    end
%     if raw(end) == '}'
%         curr_stack(end) = [];
%     end
    assert(isempty(curr_stack));
%     assert(isempty(curr_stack_keys));
end

function data = readSingle(raw)
    if raw(1) == '"'
        data = raw(2:end);
    elseif raw(1) == 't'
        data = true;
    elseif raw(1) == 'f'
        data = false;
    elseif raw(1) == 'n'
        data = NaN;
    else
        data = str2double(raw);
    end
end

% function data = doObj(raw)
%     stack_ref = containers.Map( ...
%         {'{', '[', '"', 'n', 't', 'f'}, ...
%         {'1}', '1]', '2"', '2l', '1e', '1e'});
%     num_close = {',', '}'};
%     
%     raw = raw(2:end-1);
%     curr_stack = [];
%     key_listen = true;
%     key_idx = [];
%     key_start = false;
%     curr_key = '';
%     for i = 1:length(raw)
%         if ~isspace(raw(i)) && key_listen
%             if raw(i) == '"'
%                 key_start = ~key_start;
%                 key_idx(end + 1) = i;
%             end
%             if ~key_start && ~isempty(key_idx)
%                 curr_key = raw(key_idx(end-1)+1:key_idx(end)-1);
%                 key_idx = [];
%             end
%         elseif ~isspace(raw(i))
%             if any(strcmp(raw(i), stack_ref.keys))
%                 curr_stack(end + 1) = i;
%                 v = stack_ref(raw(i));
%                 target_count = str2double(v(1));
%                 end_chars = {v(2)};
%             elseif ~isnan(str2double(raw(i)))
%                 curr_stack(end + 1) = i;
%                 target_count = 1;
%                 end_chars = num_close;
%             end
%             
%         end
%         if any(strcmp(raw(i), {':'})) && isempty(curr_stack)
%             key_listen = ~key_listen;
%         end
%     end
% end
% 
% 
% function data = newReadObj(raw)   
%     data = struct();
%     curr_key = '';
%     key_start = false;
%     key_idx = [];
%     key_listen = false;
%     for i = 1:length(raw)
%         if ~isspace(raw(i)) && key_listen
%             if raw(i) == '"'
%                 key_start = ~key_start;
%                 key_idx(end + 1) = i;
%             end
%             if ~key_start && ~isempty(key_idx)
%                 curr_key = [curr_key '.' raw(key_idx(end-1)+1:key_idx(end)-1)];
%                 fieldPath = split(curr_key, '.');
%                 data = setfield(data, fieldPath{2:end}, []);
%                 key_idx = [];
%             end
%         elseif ~isspace(raw(i))
%             raw(i)
%         end
%         if any(strcmp(raw(i), {'{', ':'}))
%             key_listen = ~key_listen;
%         end
%     end
% end
% 
% % function data = parser(raw)
% %     stack_ref = containers.Map({'{', '['}, {'}', ']'});
% %     raw = strtrim(raw);
% %     
% %     curr_stack = [];
% %     
% %     for i = 1:length(raw)
% %         if any(strcmp(raw(i), {'{' '['}))
% %             curr_stack(end + 1) = i;
% %         elseif stack_ref(raw(curr_stack(end))) == raw(i)
% %             if raw(i) == '}'
% %                 data = readObj(raw(curr_stack(end):i));
% %             elseif raw(i) == ']'
% %                 data = readArray(raw(curr_stack(end):i));
% %             end
% %         end
% %         
% %         
% %         
% %         
% %         
% % %         element = regexp(element, '(?<key>.*):(?<value>.*)', 'names');
% % %         key = strtrim(element{1}.key);
% % %         value = strtrim(element{1}.value);
% % %         if value(1) == '{'
% % %             value = readObj(value);
% % %         elseif value(1) == '['
% % %             value = readArray(value);
% % %         else
% % %             value = readSingle(value);
% % %         end      
% %     end
% % end
% 
% function data = readObj(raw)
%     stack_ref = containers.Map( ...
%         {'{', '[', '"', 'n', 't', 'f'}, ...
%         {'1}', '1]', '2"', '2l', '1e', '1e'});
%     num_close = {',', '}'};
%     
%     target_count = 0;
%     end_chars = {};
%     is_char = false;
%     close_count = 0;
%     curr_stack = [];
%     curr_stack_keys = {};
%     key = '';
%     value = [];
% %     data = containers.Map();
%     data = struct();
%     
%     raw = strtrim(raw);
% %     raw = raw(2:end-1);
%     for i = 1:length(raw)
%         if any(strcmp(raw(i), stack_ref.keys)) && ~is_char
%             curr_stack(end + 1) = i;
%             v = stack_ref(raw(i));
%             target_count = str2double(v(1));
%             end_chars = {v(2)};
%         elseif ~isnan(str2double(raw(i))) && ~is_char
%             curr_stack(end + 1) = i;
%             target_count = 1;
%             end_chars = num_close;
%         end
%         if raw(i) == ':'
%             key = value;
%             curr_stack_keys{end + 1} = value;
%         elseif raw(i) == '"'
%             is_char = ~is_char;            
%         end
%         if ~isempty(end_chars) && any(strcmp(raw(i), end_chars))
%             close_count = close_count + 1;
%         end
% %         if ~isempty(curr_stack) && stack_ref(raw(curr_stack(end))) == raw(i) && i ~= curr_stack(end)
%         if ~isempty(end_chars) && close_count == target_count
%             if raw(i) == '}' && i ~= length(raw)
%                 value = readObj(raw(curr_stack(end):i));
%             elseif raw(i) == ']'
%                 value = readArray(raw(curr_stack(end):i));
%             elseif raw(i) == '"'
%                 value = raw(curr_stack(end)+1:i-1);
%             else
%                 value = readSingle(raw(curr_stack(end):i-1));
%             end
%             if ~isempty(key)
% %                 data(key) = value;
%                 data.(key) = value;
%                 key = '';
%                 curr_stack_keys{end} = [];
%                 value = [];
%             end
%             close_count = 0;
%             end_chars = {};
%             curr_stack(end) = [];
%         end
%     end
%     if raw(end) == '}'
%         curr_stack(end) = [];
%     end
%     assert(isempty(curr_stack));
%     assert(isempty(curr_stack_keys));
% end
% 
% function data = readArray(raw)    
%     stack_ref = containers.Map( ...
%         {'{', '[', '"', 'n', 't', 'f'}, ...
%         {'1}', '1]', '2"', '2l', '1e', '1e'});
%     num_close = {',', ']'};
%     
%     target_count = 0;
%     end_chars = '';
%     close_count = 0;
%     curr_stack = [];
%     value = [];
% %     data = containers.Map();
%     data = [];
%     
%     raw = strtrim(raw);
% %     raw = raw(2:end-1);
%     for i = 1:length(raw)     
%         if any(strcmp(raw(i), stack_ref.keys))
%             curr_stack(end + 1) = i;
%             v = stack_ref(raw(i));
%             target_count = str2double(v(1));
%             end_chars = {v(2)};
%         elseif ~isnan(str2double(raw(i))) && isnan(str2double(raw(i-1))) && ~strcmp(raw(i-1),'.')
%             curr_stack(end + 1) = i;
%             target_count = 1;
%             end_chars = num_close;
%         end
%         if ~isempty(end_chars) && any(strcmp(raw(i), end_chars))
%             close_count = close_count + 1;
%         end
% %         if ~isempty(curr_stack) && stack_ref(raw(curr_stack(end))) == raw(i) && i ~= curr_stack(end)
%         if ~isempty(end_chars) && close_count == target_count
%             if raw(i) == '}' && i ~= length(raw)
%                 value = readObj(raw(curr_stack(end):i));
%             elseif raw(i) == ']' && i ~= length(raw)
%                 value = readArray(raw(curr_stack(end):i));
%             elseif raw(i) == '"'
%                 value = raw(curr_stack(end)+1:i-1);
%             else
%                 value = readSingle(raw(curr_stack(end):i-1));
%             end
%             if value
%                 data(end+1) = value;
%             end
%             close_count = 0;
%             end_chars = {};
%             curr_stack(end) = [];
%         end
%     end
%     if raw(end) == ']'
%         curr_stack(end) = [];
%     end
%     assert(isempty(curr_stack));
%     
% end

