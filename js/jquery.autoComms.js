(function($) {

    $.fn.autoComms = function() {
    	function addCommas(nStr){
    		var rgx, x, x1, x2;
			nStr += "";
			x = nStr.split(".");
			if (x.length === 1) {
			nStr = x[0] + ".00";
			x = nStr.split(".");
			}
			x1 = x[0];
			x1 = x1.replace(/,/g, "");
			x2 = "." + x[1];
			rgx = /(\d+)(\d{3})/;
			while (rgx.test(x1)) {
			x1 = x1.replace(rgx, "$1" + "," + "$2");
			}
			return x1 + x2;
    	};
    	function getCommas(element){
    		var result = element.val().match(/,/g);
			if(result == null)
				return 0;
			else
				return result.length;
    	}
    	function getCursorPosition(element){
    		var input = element.get(0);
    		if (!input) return; // No (input) element found
	        if ('selectionStart' in input) {
	            // Standard-compliant browsers
	            return input.selectionStart;
	        } else if (document.selection) {
	            // IE
	            input.focus();
	            var sel = document.selection.createRange();
	            var selLen = document.selection.createRange().text.length;
	            sel.moveStart('character', -input.value.length);
	            return sel.text.length - selLen;
	        }
    	}
    	function setCursorPosition(node,pos){
		    var node = (typeof node == "string" || node instanceof String) ? document.getElementById(node) : node;
		    if(!node){
		        return false;
		    }else if(node.createTextRange){
		        var textRange = node.createTextRange();
		        textRange.collapse(true);
		        textRange.moveStart('character', pos);
   				textRange.moveEnd('character', 0);
		        textRange.select();
		        return true;
		    }else if(node.setSelectionRange){
		        node.setSelectionRange(pos,pos);
		        return true;
		    }
		    return false;
		}
    	function toCurrency(element){
    		var comms_counter = getCommas(element);
    		var cur_cursor = getCursorPosition(element);
			element.val(addCommas(element.val()));
			var result = element.val().match(/,/g);
			if(result == null){
				setCursorPosition(element, cur_cursor);
				if(comms_counter == 1){
					setCursorPosition(element, cur_cursor - 1);
					comms_counter = 0;
				}
			}else{
				if(comms_counter > result.length)
					setCursorPosition(element, cur_cursor - 1);
				else if(comms_counter < result.length)
					setCursorPosition(element, cur_cursor + 1);
				else
					setCursorPosition(element, cur_cursor);
				comms_counter = result.length;
			}
			return comms_counter;
    	}
        return this.each( function() {
        	$(this).val("0.00");
        	toCurrency($(this));

        	$(this).on('keypress',function(event){
        		if(event.which < 48 || event.which > 57)
					event.preventDefault();
        	})
            $(this).on('input',function(event){
            	if($.isNumeric($(this).val().replace(/[^0-9\.-]+/g,"")))
					toCurrency($(this));
				else{
					$(this).val("0.00");
					alert("asd");
					setCursorPosition($(this), 0);
				}
            });
        });
    }

}(jQuery));