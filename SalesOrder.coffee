$ ->
	cur_SO = 1 #default for selecting current SO
	Chart.defaults.global.responsive = true
	Chart.defaults.global.maintainAspectRatio = false
	window.onload = ->
		LoadSOHistory('/SO/GetAllSOHistory')
	
		$("#sales_id").trigger("change")
		$(".summary .details").niceScroll({touchbehavior:false,cursorcolor:"#e8eded",cursoropacitymax:1,cursorwidth:6})
		$("#so_nota_input #nota_body_wrapper, #so_nota_history #nota_body_wrapper").niceScroll({touchbehavior:false,cursorcolor:"#e8eded",cursoropacitymax:1,cursorwidth:6})
		$(".printpage").addClass("hide")
		
		if $("#so_success_input").length is 1 or flashing_insert is false
			LoadCurrentDate('#so_additional_input', 30)
		else
			if $("#so_header_input #customer_id").val() isnt ""
				LoadCustomerDetails("/SO/GetCustomerDetail/" + encodeURIComponent($("#so_header_input #customer_id").val()), "input")
				LoadCustomerSO("/SO/GetCustomerSO/" + encodeURIComponent($("#so_header_input #customer_id").val()))
				LoadCustomerPayable("/SO/GetCustomerPayable/" + encodeURIComponent($("#so_header_input #customer_id").val()))
				LoadCustomerAvgPayment("/SO/GetCustomerAvgPayment/" + encodeURIComponent($("#so_header_input #customer_id").val()))
			if $("#so_nota_input .nota_body tbody").html() isnt ""
				reCalculate($('#so_nota_input #nota_body_wrapper tr'),$('#so_nota_input #sub_total'),$('#so_nota_input #total_discount'),$('#so_nota_input #tax'),$('#so_nota_input .total_so'))  

		if $("#so_success_history").length is 1 or flashing_update is false
			cur_SO = 1
			LoadCurrentDate('#so_additional_history', 30)
		else
			cur_SO = 0
			if $("#so_header_history #customer_id").val() isnt ""
				LoadCustomerDetails("/SO/GetCustomerDetail/" + encodeURIComponent($("#so_header_history #customer_id").val()), "history")
				LoadCustomerSO("/SO/GetCustomerSO/" + encodeURIComponent($("#so_header_history #customer_id").val()))
				LoadCustomerPayable("/SO/GetCustomerPayable/" + encodeURIComponent($("#so_header_history #customer_id").val()))
				LoadCustomerAvgPayment("/SO/GetCustomerAvgPayment/" + encodeURIComponent($("#so_header_history #customer_id").val()))
			if $("#so_nota_history .nota_body tbody").html() isnt ""
				reCalculate($('#so_nota_history #nota_body_wrapper tr'),$('#so_nota_history #sub_total'),$('#so_nota_history #total_discount'),$('#so_nota_history #tax'),$('#so_nota_history .total_so'))  
		return

	$(document).on "click", (event) ->
		if event.target.id isnt "customer_search_bar"
			search_customer = $(".search_customer")
			if search_customer.css("display") is "block"
				clearTimeout searchCustomerTimeout
				search_customer.scrollTop(0)
				search_customer.css("display", "none")
				customer_current_search_position = -1
		
		if event.target.id isnt "so_search_bar"
			search_so = $(".search_so")
			if search_so.css("display") is "block"
				clearTimeout searchSOTimeout
				search_so.scrollTop(0)
				search_so.css("display", "none")
				so_current_search_position = -1

	LoadCurrentDate = (element, days) ->
		now = new Date();
		day = ("0" + now.getDate()).slice(-2)
		month = ("0" + (now.getMonth() + 1)).slice(-2)
		today = now.getFullYear()+"-"+(month)+"-"+(day)
		$(element+' #so_date').val(today)
		$(element+' #due_date').prop('min',today)
		now = new Date();
		now.setDate(now.getDate() + days);
		day = ("0" + now.getDate()).slice(-2)
		month = ("0" + (now.getMonth() + 1)).slice(-2)
		today = now.getFullYear()+"-"+(month)+"-"+(day)
		$(element+' #due_date').val(today)
		$(element+' #terms').val(days)

	# @CUSTOMER | START #######

	mouseover_customer_enable = true
	customer_current_search_position = -1
	customer_search_counter = 0
	searchCustomerTimeout = 0
	loadCustomerLock = 0

	LoadCustomerSearch = (route)->
		if loadCustomerLock is 0
			loadCustomerLock = 1
			$table = $('.search_customer')
			CustomerListUrl = route
			$table.html("")
			customer_search_counter = 0
			customer_current_search_position = -1

			$.get CustomerListUrl, (customer) ->		
				$.each customer, (index, list) ->
					row = $("<tr class='search_row' id="+list.id+"/>").append $("<td class='search_node' id='search_node_" + customer_search_counter + "'/>").text(list.name)
					customer_search_counter++
					$table.append row
			.done (->
				loadCustomerLock = 0
				$table.css("display", "block")

				if customer_search_counter < 4
					$table.css("height",18*customer_search_counter+"px")
				else
					$table.css("height",18*4+"px")

				$table.niceScroll({touchbehavior:false,cursorcolor:"#e8eded",cursoropacitymax:1,cursorwidth:6});
			)

	maxNota = 0
	LoadCustomerSO = (CustomerSOUrl)->	
		$.get CustomerSOUrl, (CustomerSO) ->
			div = $('.SalesOrders .nav_list ul div')
			div.find("li").each ->
				if $(this).find("a").attr("id") isnt "nav_cr"
					$(this).remove()

			for i in [0..CustomerSO.length-1] by 1
				counter = i + 1
				div.append("<li><a class='nav_node' title='"+CustomerSO[i]+"' id="+CustomerSO[i]+"><span>"+counter+"</span></a></li>")	
			maxNota = CustomerSO.length - 5

			if CustomerSO.length > 5
				div.css("overflow","hidden")
				div.css("height","382px")
			else
				list_height = 64*CustomerSO.length+62
				div.css("height", list_height+"px")
				
	LoadCustomerDetails = (CustomerUrl, element)->
		$.get CustomerUrl, (Customer) ->
			info = $(".customers .info")
			info.find("input").data("id", Customer.id)
			info.find("input").val(Customer.name.replace(/'/g, "&#39;"))
			info.find(".street").text(Customer.address.replace(/'/g, "&#39;"))
			info.find(".city").text(Customer.city.replace(/'/g, "&#39;"))
			info.find(".province").text(Customer.province.replace(/'/g, "&#39;"))
			$(".customers .photo").attr("src", Customer.photo)

			block1 = $("#so_header_"+ element)
			block1.find("#customer_id").val(Customer.id)
			block1.find("#customer_name").text(Customer.name.replace(/'/g, "&#39;"))
			block1.find("#customer_addr").text(Customer.address.replace(/'/g, "&#39;"))
			block1.find("#deliver_to_addr").val(Customer.address.replace(/'/g, "&#39;"))
			block1.find("#deliver_to_city").val(Customer.city.replace(/'/g, "&#39;"))

			block2 = $("#so_additional_"+ element)
			block2.find("#credit_limit").val(addCommas(Customer.credit_limit))
			block2.find("#credit_limit").attr("title", addCommas(Customer.credit_limit))
			block2.find("#current_credit").val(addCommas(Customer.current_credit))
			block2.find("#current_credit").attr("title", addCommas(Customer.current_credit))
			block2.find("#current_credit").data("current_credit", addCommas(Customer.current_credit))
			$("#so_additional_input").find("#current_credit").data("current_credit",Customer.current_credit)
			$("#so_additional_history").find("#current_credit").data("current_credit",Customer.current_credit)

			block2.find("#terms").val(Customer.terms)
			block2.find("#sales_id").val(Customer.sales_id)
			block2.find("#terms").trigger("input")

			block3 = $("#so_nota_"+ element)
			block3.find("#tax").data("tax", (Customer.tax/100))
			block3.find("#tax_form").val(Customer.tax)
			block3.find("#tax").siblings(".total_name").text("Tax "+Customer.tax+"% (IDR)")

			$("#inventory_nav").removeClass("hide")
			$('#get_all_products').trigger("click")

			LoadCustomerSO("/SO/GetCustomerSO/" + encodeURIComponent(Customer.id))
			LoadCustomerPayable("/SO/GetCustomerPayable/" + encodeURIComponent(Customer.id))
			LoadCustomerAvgPayment("/SO/GetCustomerAvgPayment/" + encodeURIComponent(Customer.id))
			LoadCustomerProfit("/SO/GetCustomerProfit/" + encodeURIComponent(Customer.id))

	LoadCustomerDetails1 = (CustomerUrl, element)->
		$.get CustomerUrl, (Customer) ->
			info = $(".customers .info")
			info.find("input").data("id", Customer.id)
			info.find("input").val(Customer.name.replace(/'/g, "&#39;"))
			info.find(".street").text(Customer.address.replace(/'/g, "&#39;"))
			info.find(".city").text(Customer.city.replace(/'/g, "&#39;"))
			info.find(".province").text(Customer.province.replace(/'/g, "&#39;"))
			$(".customers .photo").attr("src", Customer.photo)

			if element is "input"
				block = $("#so_nota_"+ element)
				block.find("#tax").data("tax", (Customer.tax/100))
				block.find("#tax_form").val(Customer.tax)
				block.find("#tax").siblings(".total_name").text("Tax "+Customer.tax+"% (IDR)")

			#block2 = $("#so_additional_"+ element)
			#block2.find("#credit_limit").val(addCommas(Customer.credit_limit))
			#block2.find("#credit_limit").attr("title", addCommas(Customer.credit_limit))
			#block2.find("#current_credit").data("current_credit", addCommas(Customer.current_credit))

			$("#inventory_nav").removeClass("hide")
			$('#get_all_products').trigger("click")

			LoadCustomerSO("/SO/GetCustomerSO/" + encodeURIComponent(Customer.id))
			LoadCustomerPayable("/SO/GetCustomerPayable/" + encodeURIComponent(Customer.id))
			LoadCustomerAvgPayment("/SO/GetCustomerAvgPayment/" + encodeURIComponent(Customer.id))
			LoadCustomerProfit("/SO/GetCustomerProfit/" + encodeURIComponent(Customer.id))

	LoadCustomerDetails2 = (CustomerUrl, element)->
		customer_id = ""
		$.get CustomerUrl, (Customer) ->
			block2 = $("#so_additional_"+ element)
			block2.find("#credit_limit").val(addCommas(Customer.credit_limit))
			block2.find("#credit_limit").attr("title", addCommas(Customer.credit_limit))
			customer_id = Customer.id
			#block2.find("#current_credit").data("current_credit", addCommas(Customer.current_credit))
		.done(->
			LoadCustomerCredit("/SO/GetCustomerCredit/" + encodeURIComponent(customer_id), "history")
		)

	$(".info .name").on "input", (event) ->
		if $(".info .name").val() isnt ""
			clearTimeout searchCustomerTimeout
			searchCustomerTimeout = setTimeout(->
			  LoadCustomerSearch("/SO/GetCustomer/" + encodeURIComponent($(".info .name").val()))
			  return
			, 500)
		else
			clearTimeout searchCustomerTimeout
			$('.search_customer').scrollTop(0)
			$(".search_customer").css("display", "none")
			customer_current_search_position = -1

	$(".info .name").keydown (e) ->
		if $('.search_customer').css('display') is 'block' 
			if e.keyCode is 40
				e.preventDefault()
				mouseover_customer_enable = false
				if customer_current_search_position < customer_search_counter-1
					$('.search_node').removeClass('search_choose');
					customer_current_search_position++
					$('#search_node_' + customer_current_search_position).addClass('search_choose')
					$('.search_customer').scrollTop(18*(customer_current_search_position))
			else if e.keyCode is 38
				e.preventDefault()
				mouseover_customer_enable = false
				if customer_current_search_position > 0
					$('.search_customer .search_node').removeClass('search_choose');
					customer_current_search_position--
					$('#search_node_' + customer_current_search_position).addClass('search_choose')
					$('.search_customer').scrollTop(18*(customer_current_search_position))
			else if e.keyCode is 39 or e.keyCode is 13
				if customer_current_search_position isnt -1 and confirm("Any changes won't be saved. Do you want to continue ?") is true
					e.preventDefault()
					clearTimeout searchCustomerTimeout
					$(".info .name").val($('#search_node_' + customer_current_search_position).text())
					$('.search_customer').scrollTop(0)
					$(".search_customer").css("display", "none")
					$( ".nav_list #nav_cr" ).trigger( "click" )
					clearForm("input")
					LoadCustomerDetails("/SO/GetCustomerDetail/" + encodeURIComponent($('#search_node_' + customer_current_search_position).parent().attr("id")), "input")
					customer_current_search_position = -1

	$('.search_customer').on 'click', '.search_node', (event) ->
		if confirm("Any changes won't be saved. Do you want to continue ?") is true
			clearTimeout searchCustomerTimeout
			$('.search_customer').scrollTop(0)
			$(".info .name").val $(this).text()
			$(".search_customer").css("display", "none")
			$( ".nav_list #nav_cr" ).trigger( "click" )
			customer_current_search_position = -1
			clearForm("input")
			LoadCustomerDetails("/SO/GetCustomerDetail/" + encodeURIComponent($(this).parent().attr("id")), "input")

	$(".info .name").focusout ->
		clearTimeout searchCustomerTimeout
		$('.search_customer #search_node_' + customer_current_search_position).removeClass('search_choose')
		customer_current_search_position = -1

	$('.search_customer').on 'mouseover', '.search_node', (event) ->
		if mouseover_customer_enable
			id_length = $(this).attr("id").length
			id_str = $(this).attr("id")
			customer_current_search_position = id_str.substring(12,id_length)
			$('.search_customer .search_node').removeClass('search_choose');
			$(this).addClass('search_choose')

	$('.info').on 'mousemove', (event) ->
		mouseover_customer_enable = true

	# @CUSTOMER | END ########

	# @GRAPH | START ########

	Highcharts.setOptions
	    chart: 
	        style: 
	            fontFamily: 'robotoRegular'

	$(".graph").highcharts
		chart:
			type: "column"

		title:
			text: "PROFITABILITY (in million)"
			style:
				color: "#117c9f"

		legend:
			enabled: true

		credits:
			enabled: false

		xAxis:
			lineWidth: 0
			tickWidth: 0
			labels:
				style:
					color: "#117c9f"

		yAxis:
			min: 0
			title: null
			gridLineColor: '#b3b3b3'
			tickColor: '#b3b3b3'
			labels:
				style:
					color: "#117c9f"

		tooltip:
			headerFormat: 	"<span style=\"color:#117c9f;font-size:12px\">{point.key}</span><table>"
			pointFormat: 	"<tr><td style=\"color:{series.color};padding:0\">{series.name}: </td>" + "<td style=\"color:#117c9f;padding:0\"><b>{point.y:,.2f}</b></td></tr>"
			footerFormat: 	"</table>"
			shared: true
			useHTML: true

		plotOptions:
	        column:
	            grouping: false
	            shadow: false
	            borderWidth: 0

	$(".graph1").highcharts
		chart:
			type: "area"

		title:
			text: "AVG. PAYMENT"
			style:
				color: "#117c9f"

		legend:
			enabled: false

		credits:
		  	enabled: false

		xAxis:
			lineWidth: 0
			tickWidth: 0
			labels:
				style:
					color: "#117c9f"

		yAxis:
			min: 0
			title: null
			gridLineColor: '#b3b3b3'
			tickColor: '#b3b3b3'
			labels:
				style:
					color: "#117c9f"

		tooltip:
			headerFormat: 	"<span style=\"color:#117c9f; font-size:12px\">{point.key}</span><table>"
			pointFormat: 	"<tr><td style=\"color:{series.color};padding:0\">{series.name}: </td>" + "<td style=\"color:#117c9f;padding:0\"><b>{point.y:.2f}</b></td></tr>"
			footerFormat: 	"</table>"
			shared: true
			useHTML: true

	LoadCustomerPayable = (CustomerUrl) ->
		$.get CustomerUrl, (CustomerPayable) ->
			summary_table = $(".summary").find(".details table")
			summary_table.html('')
			content_string = ""
			for i in [0..CustomerPayable.length - 1] by 1
				content_string += "<tr>"
				content_string += "<td class='info'>"+CustomerPayable[i].id+"</td>"
				content_string += "<td class='value'>"+addCommas((CustomerPayable[i].unpaid_amount).toFixed(2))+"</td>"
				content_string += "</tr>"

			summary_table.append(content_string)
			total_unpaid = 0
			summary_table.find("td.value").each ->
				total_unpaid += Number($(this).text().replace(/[^0-9\.-]+/g,""))
			$(".summary").find("table.total_amount td.value").text(addCommas(total_unpaid.toFixed(2)))

	LoadCustomerProfit = (CustomerUrl) ->
		$.get CustomerUrl, (CustomerProfit) ->
			chart = $('.graph').highcharts()

			while(chart.series.length > 0)
 				chart.series[0].remove()

			if CustomerProfit.length isnt 0
				monthNames = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
				label_arr = []
				sales_arr = []
				cogs_arr = []
				profit_arr = []
				divider = 1000000 #1 million

				for i in [0..CustomerProfit.length - 1] by 1
					label_arr.push monthNames[CustomerProfit[i].monthly - 1]
					sales_arr.push CustomerProfit[i].Sales / divider
					cogs_arr.push CustomerProfit[i].COGS / divider
					profit_arr.push CustomerProfit[i].Profit / divider

				chart.xAxis[0].setCategories(label_arr)
				chart.addSeries(name: "Sales", color: '#98DEE9', data: sales_arr, pointPadding: 0)
				chart.addSeries(name: "COGS", color: '#6EC4CD', data: cogs_arr, pointPadding: 0.1)
				chart.addSeries(name: "Profit", color: '#2A8A9A', data: profit_arr, pointPadding: 0.2)

		
	LoadCustomerAvgPayment = (CustomerUrl) ->
		$.get CustomerUrl, (CustomerAvgPayment) ->
			chart = $('.graph1').highcharts()

			while(chart.series.length > 0)
 				chart.series[0].remove()

			if CustomerAvgPayment.length isnt 0
				monthNames = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
				label_arr = []
				data_arr = []

				for i in [0..CustomerAvgPayment.length - 1] by 1
					label_arr.push monthNames[CustomerAvgPayment[i].monthly - 1]
					data_arr.push CustomerAvgPayment[i].avg_val

				chart.xAxis[0].setCategories(label_arr)
				chart.addSeries(name: "Days", color: '#6EC4CD', marker: {symbol: 'circle'}, data: data_arr)
				

	$(".summary .details table").on "click", ".info", (event) ->
		$("#so_header_input").addClass("hide")
		$("#so_header_history").removeClass("hide")
		$("#so_additional_input").addClass("hide")
		$("#so_additional_history").removeClass("hide")
		$("#so_nota_input").addClass("hide")
		$("#so_nota_history").removeClass("hide")

		$("#approve_button_input").addClass("hide")
		$("#save_button_input").addClass("hide")
		$("#clear_button_input").addClass("hide")

		$("#so_error_input").addClass("hide")
		$("#so_success_input").addClass("hide")
		$("#so_error_history").removeClass("hide")
		$("#so_success_history").removeClass("hide")
		cur_SO = 0 #opening PO history
		LoadSObyID("/SO/GetSO/" + $(this).text())

	# @GRAPH | END #######

	# @INVENTORY_ITEM | START #######

	getDate = (timestamp)->
		monthNames = [
		  "Jan"
		  "Feb"
		  "Mar"
		  "Apr"
		  "May"
		  "Jun"
		  "Jul"
		  "Aug"
		  "Sep"
		  "Oct"
		  "Nov"
		  "Dec"
		]
		currentdate = new Date(timestamp)
		if currentdate.getDate() < 10
			dates = "0" + currentdate.getDate()  
		else
			dates = currentdate.getDate()
		datetime = dates + "-" + (monthNames[currentdate.getMonth()])  + "-" + currentdate.getFullYear()


	LoadProduct = (route)->
		$table = $('#table_product')
		productListUrl = route
		$table.html("")

		$("#inventory #table_content").block
			message: "<h1>Processing . . .</h1>"
			css:
			  border: 'none', 
			  padding: '15px',
			  backgroundColor: '#000',
			  '-webkit-border-radius': '10px', 
			  '-moz-border-radius': '10px', 
			  opacity: .5, 
			  color: '#fff'

		$.get productListUrl, (products) ->
			$.each products, (index, list) ->
				if list.id isnt ''
					$table.append("<tr><td class='th1'><span title='"+list.id+"''>"+list.id+"</span></td>
									<td class='th2'><span title='"+list.name.replace(/'/g, "&#39;")+"''>"+list.name.replace(/'/g, "&#39;")+"</span></td>
									<td class='th3'><span title='"+list.category_name.replace(/'/g, "&#39;")+"''>"+list.category_name.replace(/'/g, "&#39;")+"</span></td>
									<td class='th4'><span title='"+list.stock+"''>"+list.stock+"</span></td>
									<td class='th5'><span title='"+addCommas(Number(list.price).toFixed(2))+"''>"+addCommas(Number(list.price).toFixed(2))+"</span></td></tr>")
		.done (->
			$("#inventory #table_content").niceScroll({touchbehavior:false,cursorcolor:"#e8eded",cursoropacitymax:1,cursorwidth:6})
			$("#inventory #table_content").unblock()
		)

	UnitSelect = (selectElement, multiplier, name)->
		notSelected = true
		$(selectElement).find("option").each ->
			if Number($(this).val()) is multiplier and $(this).text() is name
				$(this).attr("selected","selected");
				notSelected = false
		
		if notSelected
			$(selectElement).append("<option value='"+multiplier+"' selected='selected'>"+name+"</option>")

	LoadProductUnit = (route, target, selected_index, multiplier, name, select)->
		$.get route, (units) ->
			$.each units, (index, list) ->
				$(target + " #unit_multiplier"+selected_index).append("<option value='"+list.unit_multiplier+"'>"+list.unit_name+"</option>")
				
				if list.status is 1 and select is 0
					$(target + " #unit_name"+selected_index).val(list.unit_name)
		.done (->
			if select is 1
				UnitSelect(target + " #unit_multiplier"+selected_index, multiplier, name)
		)

	selectedSO = ->
		$("#table_so tr").removeClass("selected")
		$("#table_so tr .th1 span").filter(->
			$(this).text() is $("#so_additional_history #so_id").val()
		).parents("tr").addClass("selected")

	LoadSOHistory = (route)->
		$table = $('#table_so')
		$table.html("")

		$("#sales_order #table_content").block
			message: "<h1>Processing . . .</h1>"
			css:
			  border: 'none', 
			  padding: '15px',
			  backgroundColor: '#000',
			  '-webkit-border-radius': '10px', 
			  '-moz-border-radius': '10px', 
			  opacity: .5, 
			  color: '#fff'

		$.get route, (so) ->
			$.each so, (index, list) ->

				if list.status is 0
					status = "Draft"
				else if list.status is 10
					status = "Awaiting Approval"
				else if list.status is 20
					status = "Approved"
				else if list.status is 21
					status = "Recaped"
				else if list.status is 23
					status = "Confirmed"
				else if list.status is 25
					status = "Received"
				else
					status = "Finished"

				if list.approved isnt ""
					lastedit = list.approved
				else if list.lastedited is ""
					lastedit = "-"
				else
					lastedit = list.lastedited

				$table.append("<tr><td class='th1'><span title="+list.id+">"+list.id+"</span></td>
								<td class='th2'><span title="+list.customer_id+">"+list.customer_id+"</span></td>
								<td class='th3'><span>"+getDate(list.so_date)+"</span></td>
								<td class='th4'><span title="+list.submitted+">"+list.submitted+"</span></td>
								<td class='th5'><span title="+lastedit+">"+lastedit+"</span></td>
								<td class='th6'><span>"+status+"</span></td></tr>")
		.done (->
			$("#sales_order #table_content").niceScroll({touchbehavior:false,cursorcolor:"#e8eded",cursoropacitymax:1,cursorwidth:6})
			$("#sales_order #table_content").unblock()

			selectedSO()
		)

	LoadRCHeader = (route)->
		$table = $('#table_rc')
		$table.html("")

		$("#return_customer #table_content").block
			message: "<h1>Processing . . .</h1>"
			css:
			  border: 'none', 
			  padding: '15px',
			  backgroundColor: '#000',
			  '-webkit-border-radius': '10px', 
			  '-moz-border-radius': '10px', 
			  opacity: .5, 
			  color: '#fff'

		$.get route, (rc) ->
			$.each rc, (index, list) ->
				if list.approved isnt ""
					lastedit = list.approved_id
				else if list.edited_id is ""
					lastedit = "-"
				else
					lastedit = list.edited_id

				$table.append("<tr><td class='th1'><span title='"+list.id+"'>"+list.id+"</span></td>
										<td class='th2'><span>"+getDate(list.rc_date)+"</span></td>
										<td class='th3'><span title='"+list.submitted_id+"'>"+list.submitted_id+"</span></td>
										<td class='th4'><span title='"+lastedit+"'>"+lastedit+"</span></td></tr>")
		.done (->
			$("#return_customer #table_content").niceScroll({touchbehavior:false,cursorcolor:"#e8eded",cursoropacitymax:1,cursorwidth:6})
			$("#return_customer #table_content").unblock()

			#selectedSO()
		)

	LoadReturnDetails = (route)->
	
		if cur_SO is 1
			id_selector = "#so_nota_input"
		else
			id_selector = "#so_nota_history"

		content = $(id_selector + " #nota_body_wrapper table.nota_body ")

		$.get route, (rd) ->
			$.each rd, (index, list) ->
				inventory_to_nota = $(id_selector + " #nota_body_wrapper table.nota_body tr").length
				
				content_string = "<tr>"
				content_string += "<td class='col_id'><input type='text' readonly name='products["+inventory_to_nota+"].product_id' title="+list.product_id+" value="+list.product_id+"> </td>"
				content_string += "<td class='col_desc'><input type='text' readonly name='products["+inventory_to_nota+"].desc' title='"+list.name.replace(/'/g, "&#39;")+"' value='"+list.name.replace(/'/g, "&#39;")+"'></td>"
				content_string += "<td class='col_qty' id="+list.qty+"><input type='text' autocomplete='off' name='products["+inventory_to_nota+"].qty' value="+list.qty+" ></td>"
				content_string += "<td class='col_unit'><select id='unit_multiplier"+inventory_to_nota+"' name='products["+inventory_to_nota+"].unit_multiplier'></select>"
				content_string += "<input type='hidden' id='unit_name"+inventory_to_nota+"' name='products["+inventory_to_nota+"].unit_name' autocomplete='off' value='"+list.unit_name+"'/></td>"
				content_string += "<td class='col_price'><input type='text' autocomplete='off' name='products["+inventory_to_nota+"].price' data-price="+(list.price / list.unit_multiplier).toFixed(2)+" title="+addCommas((list.price).toFixed(2))+" value="+addCommas((list.price).toFixed(2))+"> </td>"
				content_string += "<td class='col_disc'><input type='text' autocomplete='off' name='products["+inventory_to_nota+"].discount' value="+list.discount+" /></td></td>"
				content_string += "<td class='col_total'><input type='text' readonly name='products["+inventory_to_nota+"].total' title="+addCommas((list.qty * list.price).toFixed(2))+" value="+addCommas((list.qty * list.price).toFixed(2))+"></td>"
				content_string += "<td class='col_contract'><input type='checkbox' name='products["+inventory_to_nota+"].contract' value='true' >"
				content_string += "<td class='col_remove'><div class='remove_image'></div></td>"
				content_string += "</tr>"
				content.append(content_string)
				LoadProductUnit("/SO/GetProductUnit/"+list.product_id, id_selector, inventory_to_nota, list.unit_multiplier, list.unit_name, 1)
			
		reCalculate($(id_selector + " #nota_body_wrapper tr"), $(id_selector + " #sub_total"), $(id_selector+' #total_discount'), $(id_selector + " #tax"), $(id_selector + " .total_so"))
		$(id_selector+" #nota_body_wrapper").getNiceScroll().resize()

	searchProductTimeout = 0
	productSearch = 0

	$("#inventory .title_text").on "input", (event) ->
		if cur_SO is 1
			id_selector = "#so_header_input"
		else if cur_SO is 0 
			id_selector = "#so_header_history"

		if $(".salesOrder "+id_selector).find("#customer_id").val() isnt ""
			if $("#inventory .title .title_text").val() isnt ""
				if productSearch is 0
				    productQuery = "/SO/GetProduct/" + encodeURIComponent($(id_selector + " #customer_id").val()) + "/" + encodeURIComponent($("#inventory .title .title_text").val())
				else
					productQuery = "/SO/GetProductHistory/" + encodeURIComponent($(id_selector + " #customer_id").val()) + "/" + encodeURIComponent($("#inventory .title .title_text").val())
			else
				if productSearch is 0
					productQuery = "/SO/GetAllProduct/" + encodeURIComponent($(id_selector + " #customer_id").val())
				else
					productQuery = "/SO/GetAllProductHistory/" + encodeURIComponent($(id_selector + " #customer_id").val())

			clearTimeout searchProductTimeout
			
			searchProductTimeout = setTimeout(->			  
			  LoadProduct(productQuery)
			  return
			, 500)

	searchSOHistoryTimeout = 0
	$("#sales_order .title_text").on "input", (event) ->
		if $("#sales_order .title .title_text").val() isnt ""
			clearTimeout searchSOHistoryTimeout
			searchSOHistoryTimeout = setTimeout(->
			  LoadSOHistory("/SO/GetSOHistory/" + encodeURIComponent($("#sales_order .title .title_text").val()))
			  return
			, 500)
		else
			clearTimeout searchSOHistoryTimeout
			searchSOHistoryTimeout = setTimeout(->
			  LoadSOHistory('/SO/GetAllSOHistory')
			  return
			, 500)

	$('#table_product').on 'click', '.th1',(event) ->
		if permission_edit or permission_insert
			id_selector = ""
			if cur_SO is 1 and permission_insert #SO belum pernah di submit
				id_selector = "#so_nota_input"
			else if cur_SO is 0 and permission_edit and SO_status < 20 #SO ingin di-edit
				id_selector = "#so_nota_history"
			if id_selector isnt ""
				inventory_to_nota = $(id_selector + " #nota_body_wrapper tr").length
				
				$(id_selector + " #nota_body_wrapper table").append("<tr id=" + $(this).text() + ">" + "
					<td class='col_id'><input type='text' readonly name='products["+inventory_to_nota+"].product_id' title=" + $(this).text() + " value=" + $(this).text() + "> 
					</td><td class='col_desc'><input type='text' readonly name='products["+inventory_to_nota+"].desc' title='" + $(this).siblings('.th2').text() + "' value='" + $(this).siblings('.th2').text() + "'>
					</td><td class='col_qty'><input type='text' autocomplete='off' name='products["+inventory_to_nota+"].qty' value='1' >
					</td><td class='col_unit'>
						<select autocomplete='off' id='unit_multiplier"+inventory_to_nota+"' name='products["+inventory_to_nota+"].unit_multiplier'></select>
						<input type='hidden' id='unit_name"+inventory_to_nota+"' name='products["+inventory_to_nota+"].unit_name'/>
					</td><td class='col_price'><input type='text' autocomplete='off' name='products["+inventory_to_nota+"].price' data-price="+$(this).siblings('.th5').text().replace(/[^0-9\.-]+/g,"")+" title="+$(this).siblings('.th5').text()+" value="+$(this).siblings('.th5').text()+"> 
					</td><td class='col_disc'><input type='text' name='products["+inventory_to_nota+"].discount' autocomplete='off' value='0' /></td>
					</td><td class='col_total'><input type='text' readonly name='products["+inventory_to_nota+"].total' title="+$(this).siblings('.th5').text()+" value="+$(this).siblings('.th5').text()+">
					</td><td class='col_contract'><input type='checkbox' name='products["+inventory_to_nota+"].contract' value='true' >
					</td><td class='col_remove'><div class='remove_image'></div></td></tr>")

				LoadProductUnit("/SO/GetProductUnit/"+encodeURIComponent($(this).text()), id_selector, inventory_to_nota, 0, 0, 0)
				reCalculate($(id_selector+' #nota_body_wrapper tr'),$(id_selector+' #sub_total'),$(id_selector+' #total_discount'),$(id_selector+' #tax'),$(id_selector+' .total_so'))
				$(id_selector+" #nota_body_wrapper").getNiceScroll().resize()

	$('#table_so').on 'click', '.th1',(event) ->
		$("#table_so tr").removeClass("selected")
		$(this).parents("tr").addClass("selected")
		
		$("#so_header_input").addClass("hide")
		$("#so_header_history").removeClass("hide")
		$("#so_additional_input").addClass("hide")
		$("#so_additional_history").removeClass("hide")
		$("#so_nota_input").addClass("hide")
		$("#so_nota_history").removeClass("hide")

		$("#approve_button_input").addClass("hide")
		$("#save_button_input").addClass("hide")
		$("#clear_button_input").addClass("hide")

		$("#so_error_input").addClass("hide")
		$("#so_success_input").addClass("hide")
		$("#so_error_history").removeClass("hide")
		$("#so_success_history").removeClass("hide")
		cur_SO = 0 #opening SO history
		LoadSObyID("/SO/GetSO/" + encodeURIComponent($(this).text()))

	$('#table_rc').on 'click', '.th1',(event) ->
		LoadReturnDetails("/SO/GetRCDetail/" + encodeURIComponent($(this).text()))

	$('#get_so').on 'click', (event) ->
		$("#sales_order").css("display","block")
		$("#inventory").css("display","none")
		LoadSOHistory('/SO/GetAllSOHistory')

	$('#get_all_products').on 'click', (event) ->
		if cur_SO is 1
			id_selector = "#so_header_input"
		else if cur_SO is 0
			id_selector = "#so_header_history"

		if $(id_selector+" #customer_id").val() isnt ""
			$("#sales_order").css("display","none")
			$("#inventory").css("display","block")
			productSearch = 0
			LoadProduct('/SO/GetAllProduct/'+encodeURIComponent($(id_selector+" #customer_id").val()))

	$('#get_product_history').on 'click', (event) ->
		if cur_SO is 1
			id_selector = "#so_header_input"
		else if cur_SO is 0
			id_selector = "#so_header_history"

		if $(id_selector+" #customer_id").val() isnt ""
			$("#sales_order").css("display","none")
			$("#inventory").css("display","block")
			productSearch = 1
			LoadProduct('/SO/GetAllProductHistory/'+encodeURIComponent($(id_selector+" #customer_id").val()))

	$('#get_rc').on 'click', (event) ->
		if cur_SO is 1
			id_selector = "#so_header_input"
		else if cur_SO is 0
			id_selector = "#so_header_history"

		$("sales_order").css("display","none")
		$("#return_customer").css("display","block")
		$("#inventory").css("display","none")

		LoadRCHeader('/SO/GetAllRCHeader/'+encodeURIComponent($(id_selector+" #customer_id").val()))

	# @INVENTORY_ITEMS | END #######

	# @PROMO | START #######

	promo = 0
	inventory_to_nota = 0
	max_promo = $('.promo .left_module ul li').length - 5 
	#default min ada 5 promo yang ditampilkan, else scroll
	scrollVal = 162

	colors = ["#6C4099", "#CD2027", "#F48E1F", "#329B46", "#33459D"]
	color_counter = 5
	counter = 0
	$('.promo .left_module ul li .top').each ->
    	$(this).css("background-color", colors[counter % color_counter])
    	counter++

	$('.promo .nav_list #next').on 'click', (event) ->
		if promo < max_promo
			promo++
			$('.promo .left_module ul').animate({scrollLeft: scrollVal * promo},"slow")

	$('.promo .nav_list #prev').on 'click', (event) ->
		if promo > 0
			promo--
			$('.promo .left_module ul').animate({scrollLeft: scrollVal * promo},"slow")

	# @PROMO | END #######

	# @SALES_ORDER | START #######

	mouseover_so_enable = true
	SO_status = -1 #default for no history selected
	so_search_counter = 0
	so_current_search_position = -1
	searchSOTimeout = 0
	loadSOLock = 0

	getDateInput = (timestamp)->
		monthNumber = [
		  "01"
		  "02"
		  "03"
		  "04"
		  "05"
		  "06"
		  "07"
		  "08"
		  "09"
		  "10"
		  "11"
		  "12"
		]
		
		currentdate = new Date(timestamp)

		if currentdate.getDate() < 10
			dates = "0" + currentdate.getDate()  
		else
			dates = currentdate.getDate()

		datetime = currentdate.getFullYear() + "-" + (monthNumber[currentdate.getMonth()]) + "-" + dates

	LoadCustomerCredit = (url, element) ->
		$.get url, (credit) ->
			additional = $("#so_additional_"+element)
			additional.find("#current_credit").data("current_credit",Number(credit))
		.done ( ->
			so_nota = $('#so_nota_history')
			reCalculate(so_nota.find("#nota_body_wrapper tr"), so_nota.find("#sub_total"), so_nota.find("#total_discount"), so_nota.find("#tax"), so_nota.find(".total_so"))
		)

	LoadNewButton = ->
		approve_button = $("#approve_button_history")
		save_button = $("#save_button_history")
		clear_button = $("#clear_button_history")
		delete_button = $("#del_record")
		nav_list = $("nav.nav_list-2")

		if SO_status is 0
			if permission_edit
				save_button.removeClass("hide").removeClass("third_btn").addClass("second_btn").val("Save")
				clear_button.removeClass("hide")
				approve_button.removeClass("hide").removeClass("second_btn").addClass("first_btn")
			else
				save_button.addClass("hide")
				clear_button.addClass("hide")
				if !permission_approve
					approve_button.addClass("hide")
				else
					approve_button.removeClass("hide")
			if permission_delete 
				delete_button.parent().removeClass("hide")
				nav_list.css("top", "596px")
			else
				nav_list.css("top", "660px")
		else if SO_status is 10
			save_button.removeClass("hide")
			clear_button.addClass("hide")
			approve_button.removeClass("hide")
			if !permission_approve
				approve_button.addClass("hide")
				save_button.addClass("hide")
			else
				approve_button.removeClass("first_btn").addClass("second_btn").css("top", "85px")
				save_button.removeClass("second_btn").addClass("third_btn").css("top", "60px").val("Reject")
			if permission_delete 
				delete_button.parent().removeClass("hide")
				nav_list.css("top", "596px")
			else
				nav_list.css("top", "660px")
		else 
			save_button.addClass("hide")
			clear_button.addClass("hide")
			approve_button.addClass("hide")
			delete_button.parent().addClass("hide")
			nav_list.css("top", "660px")

	LoadSObyID = (route)->
		SOListUrl = route
		$.get SOListUrl, (SO) ->
			header = $("#so_header_history")
			additional = $("#so_additional_history")
			if additional.find("#so_id").val() is "" 
				SO_status = SO[0][0].status
				$("#to_embed1").attr("src","/GenerateBarcode/"+encodeURIComponent(SO[0][0].id))
				LoadNewRecord(SO, header, additional)
			else if Number(additional.find("#so_id").val()) isnt SO[0][0].id
				$.prompt "Opening SO with ID "+SO[0][0].id+".<br> Note: Any changes on SO "+additional.find("#so_id").val()+" will not be saved.",
					title: "WARNING"
					buttons:
						"Continue": true
						"Cancel": false
					submit: (e, v, m, f) ->
						if v is true
							SO_status = SO[0][0].status
							$("#to_embed1").attr("src","/GenerateBarcode/"+encodeURIComponent(SO[0][0].id))
							LoadNewRecord(SO, header, additional)
							$("#so_error_history").hide()
						else
							selectedSO()
			else
				SO_status = SO[0][0].status

				if $(".customers .info").find("input").data("id") isnt SO[0][0].customer_id
					LoadCustomerDetails1("/SO/GetCustomerDetail/" + encodeURIComponent(SO[0][0].customer_id), "history", 0)

		LoadNewButton()

	LoadNewRecord = (SO, header, additional) ->
		LoadNewButton()
		content = $("#so_nota_history #nota_body_wrapper table.nota_body ")

		header.find("#customer_id").val(SO[0][0].customer_id)
		header.find("#customer_name").text(SO[0][0].customer_name.replace(/'/g, "&#39;"))
		header.find("#customer_addr").text(SO[0][0].customer_address.replace(/'/g, "&#39;"))
		header.find("#deliver_to_addr").val(SO[0][0].deliver_to_addr)
		header.find("#deliver_to_city").val(SO[0][0].deliver_to_city)
		header.find("#submitted_id").val(SO[0][0].submitted_id.replace(/'/g, "&#39;"))
		
		if SO[0][0].approved_id isnt null
			header.find("#edited_id").val(SO[0][0].approved_id.replace(/'/g, "&#39;"))
		else if SO[0][0].edited_id isnt null
			header.find("#edited_id").val(SO[0][0].edited_id.replace(/'/g, "&#39;"))

		additional.find("#so_id").val(SO[0][0].id)
		additional.find("#so_date").val(getDateInput(SO[0][0].so_date))
		additional.find("#so_date").trigger("change")
		additional.find("#terms").val(SO[0][0].terms)
		now = new Date(additional.find('#so_date').val());
		now.setDate(now.getDate() + SO[0][0].terms);
		day = ("0" + now.getDate()).slice(-2)
		month = ("0" + (now.getMonth() + 1)).slice(-2)
		today = now.getFullYear()+"-"+(month)+"-"+(day)
		additional.find("#due_date").val(today)
		additional.find("#tax_number").val(SO[0][0].tax_number)
		additional.find("#sales_id").val(SO[0][0].sales_person)
		additional.find("#sales_id").attr("title", additional.find("#sales_id").find("option:selected").text())
	
		so_nota = $('#so_nota_history')

		if SO_status is 0 or SO_status is 10
			header.find("input").not("#customer_id, #customer_name, #customer_addr, #submitted_id, #edited_id").prop("readonly",false)
			additional.find("input").not("#so_id, #credit_limit, #current_credit").prop("readonly",false)
			so_nota.find("table.nota_head").html('<tr>
							<td class="col_id"><span>ID</span></td>
							<td class="col_desc"><span>Name</span></td>
							<td class="col_qty"><span>QTY</span></td>
							<td class="col_unit"><span>Unit</span></td>
							<td class="col_price"><span>Price/Unit (IDR)</span></td>
							<td class="col_disc"><span>Disc(%)</span></td>
							<td class="col_total"><span>Total (IDR)</span></td>
							<td class="col_contract"><span>Con.</span></td>
							<td class="col_remove"><span>Del.</span></td>
						</tr>')
			content.html("")
			for i in [0..SO[1].length-1] by 1
				content_string = "<tr>"
				content_string += "<td class='col_id'><input type='text' readonly name='products["+i+"].product_id' title='"+SO[1][i].product_id+"' value='"+SO[1][i].product_id+"'></td>"
				content_string += "<td class='col_desc'><input type='text' readonly name='products["+i+"].desc' title='"+SO[1][i].name.replace(/'/g, "&#39;")+"' value='"+SO[1][i].name.replace(/'/g, "&#39;")+"'></td>"
				content_string += "<td class='col_qty'><input type='text' name='products["+i+"].qty' autocomplete='off' value='"+SO[1][i].qty+"'></td>"
				content_string += "<td class='col_unit'><select id='unit_multiplier"+i+"' name='products["+i+"].unit_multiplier'></select>"
				content_string += "<input type='hidden' id='unit_name"+i+"' name='products["+i+"].unit_name' autocomplete='off' value='"+SO[1][i].unit_name+"'/></td>"
				content_string += "<td class='col_price'><input type='text' autocomplete='off' name='products["+i+"].price' data-price="+(SO[1][i].price / SO[1][i].unit_multiplier).toFixed(2)+" title="+addCommas((SO[1][i].price).toFixed(2))+" value="+addCommas((SO[1][i].price).toFixed(2))+"> </td>"
				content_string += "<td class='col_disc'><input type='text' name='products["+i+"].discount' autocomplete='off' value="+SO[1][i].discount+"></td>"
				content_string += "<td class='col_total'><input type='text' readonly name='products["+i+"].total' title="+addCommas((SO[1][i].qty * SO[1][i].price).toFixed(2))+" value="+addCommas((SO[1][i].qty * SO[1][i].price).toFixed(2))+"></td>"
				if SO[1][i].contract is true
					content_string += "<td class='col_contract'><input type='checkbox' name='products["+i+"].contract' checked='true' value='true'></td>"
				else
					content_string += "<td class='col_contract'><input type='checkbox' name='products["+i+"].contract' value='true'></td>"
				content_string += "</td><td class='col_remove'><div class='remove_image'></div></td>"
				content_string += "</tr>"
				content.append(content_string)

				LoadProductUnit("/SO/GetProductUnit/"+SO[1][i].product_id, "#so_nota_history", i, SO[1][i].unit_multiplier, SO[1][i].unit_name, 1)
			so_nota.find("textarea").prop("readonly",false)
			so_nota.find("#handling").prop("readonly",false)
		else
			counter = 0
			header.find("input").prop("readonly",true)
			additional.find("input").prop("readonly",true)
			so_nota.find("table.nota_head").html('<tr>
							<td class="col_id"><span>ID</span></td>
							<td class="desc_history"><span>Name</span></td>
							<td class="col_qty"><span>QTY</span></td>
							<td class="col_unit"><span>Unit</span></td>
							<td class="col_price"><span>Price/Unit (IDR)</span></td>
							<td class="col_disc"><span>Disc(%)</span></td>
							<td class="col_total"><span>Total (IDR)</span></td>
							<td class="col_contract"><span>Con.</span></td>
						</tr>')
			content.html("")
			for i in [0..SO[1].length-1] by 1
				content_string = "<tr>"
				content_string += "<td class='col_id'><input type='text' readonly name='products["+counter+"].product_id' title='"+SO[1][i].product_id+"' value='"+SO[1][i].product_id+"'></td>"
				content_string += "<td class='desc_history'><input type='text' readonly name='products["+counter+"].desc' title='"+SO[1][i].name.replace(/'/g, "&#39;")+"' value='"+SO[1][i].name.replace(/'/g, "&#39;")+"'></td>"
				content_string += "<td class='col_qty'><input type='text' readonly name='products["+counter+"].qty' value='"+SO[1][i].qty+"'></td>"
				content_string += "<td class='col_unit'><select disabled='disabled' id='unit_multiplier"+counter+"' name='products["+counter+"].unit_multiplier'></select>"
				content_string += "<input type='hidden' readonly id='unit_name"+counter+"' name='products["+counter+"].unit_name' value='"+SO[1][i].unit_name+"'/></td>"
				content_string += "<td class='col_price'><input type='text' readonly autocomplete='off' name='products["+counter+"].price' data-price="+(SO[1][i].price / SO[1][i].unit_multiplier).toFixed(2)+" title="+addCommas((SO[1][i].price).toFixed(2))+" value="+addCommas((SO[1][i].price).toFixed(2))+"> </td>"
				content_string += "<td class='col_disc'><input type='text' readonly name='products["+counter+"].discount' value="+SO[1][i].discount+"></td>"
				content_string += "<td class='col_total'><input type='text' readonly name='products["+counter+"].total' title="+addCommas((SO[1][i].qty * SO[1][i].price).toFixed(2))+" value="+addCommas((SO[1][i].qty * SO[1][i].price).toFixed(2))+"></td>"
				if SO[1][i].contract is true
					content_string += "<td class='col_contract'><input type='checkbox' name='products["+counter+"].contract' disabled='true' checked='true' value='true'></td>"
				else
					content_string += "<td class='col_contract'><input type='checkbox' name='products["+counter+"].contract' disabled='true' value='true'></td>"
				content_string += "</tr>"
				content.append(content_string)
				LoadProductUnit("/SO/GetProductUnit/"+SO[1][i].product_id, "#so_nota_history", counter, SO[1][i].unit_multiplier, SO[1][i].unit_name, 1)
				counter++

				for j in [0..SO[2][i].length-1] by 1
					if SO[2][i][j].return_qty isnt 0
						return_price = SO[2][i][j].return_price * -1
						content_string = "<tr class='return'>"
						content_string += "<td class='col_id'><input type='text' readonly name='products["+counter+"].product_id' title="+SO[1][i].product_id+" value="+SO[1][i].product_id+"> </td>"
						content_string += "<td class='desc_history'><input type='text' readonly name='products["+counter+"].desc' title='"+SO[1][i].name.replace(/'/g, "&#39;")+"' value='"+SO[1][i].name.replace(/'/g, "&#39;")+"'></td>"
						content_string += "<td class='col_qty'><input readonly type='text' name='products["+counter+"].qty' value="+SO[2][i][j].return_qty*-1+" ></td>"
						content_string += "<td class='col_unit'><select disabled='disabled' id='unit_multiplier"+counter+"' name='products["+counter+"].unit_multiplier'></select>"
						content_string += "<input type='hidden' id='unit_name"+counter+"' name='products["+counter+"].unit_name' value='"+SO[2][i][j].return_name+"'/></td>"
						content_string += "<td class='col_price'><input type='text' readonly name='products["+counter+"].price' data-price="+(return_price).toFixed(2)+" title="+addCommas((return_price).toFixed(2))+" value="+addCommas(return_price.toFixed(2))+"> </td>"
						content_string += "<td class='col_disc'><input type='text' readonly name='products["+counter+"].discount' value="+0+" /></td></td>"
						content_string += "<td class='col_total'><input type='text' readonly name='products["+counter+"].total' title="+addCommas((return_price*SO[2][i][j].return_qty).toFixed(2))+" value="+addCommas((return_price*SO[2][i][j].return_qty).toFixed(2))+"></td>"
						if SO[1][i].contract is true
							content_string += "<td class='col_contract'><input type='checkbox' name='products["+counter+"].contract' disabled='true' checked='true' value='true'></td>"
						else
							content_string += "<td class='col_contract'><input type='checkbox' name='products["+counter+"].contract' disabled='true' value='true'></td>"
						content_string += "</tr>"
						content.append(content_string)
						LoadProductUnit("/SO/GetProductUnit/"+SO[1][i].product_id, "#so_nota_history", counter, SO[2][i][j].return_multiplier, SO[2][i][j].return_name, 1)
						counter++
			so_nota.find("textarea").prop("readonly",true)
			so_nota.find("#handling").prop("readonly",true)
	
		so_nota.find(".additional_note .detail_note textarea").val(SO[0][0].additional_note.replace(/'/g, "&#39;"))
		so_nota.find(".termsAndCond .detail_note textarea").val(SO[0][0].terms_and_cond.replace(/'/g, "&#39;"))
		so_nota.find(".total_so").find("#handling").val(addCommas((SO[0][0].handling).toFixed(2)))
		so_nota.find("#tax").data("tax", (SO[0][0].tax/100))
		so_nota.find("#tax_form").val(SO[0][0].tax)
		so_nota.find("#tax").siblings(".total_name").text("Tax "+SO[0][0].tax+"% (IDR)")

		if $(".customers .info").find("input").data("id") isnt SO[0][0].customer_id
			LoadCustomerDetails1("/SO/GetCustomerDetail/" + encodeURIComponent(SO[0][0].customer_id), "history")
		
		if SO_status < 20
			LoadCustomerDetails2("/SO/GetCustomerDetail/" + encodeURIComponent(SO[0][0].customer_id), "history")
		else
			additional.find("#credit_limit").val(addCommas(SO[0][0].credit_limit))
			additional.find("#credit_limit").attr("title", addCommas(SO[0][0].credit_limit))
			additional.find("#current_credit").data("current_credit",SO[0][0].current_credit)
			additional.find("#current_credit").val(addCommas(SO[0][0].current_credit))
			additional.find("#current_credit").attr("title", addCommas(SO[0][0].current_credit))

			if (SO[0][0].current_credit > SO[0][0].credit_limit)
				additional.find("#current_credit").parent().addClass("error")
				additional.find("#current_credit").parent().prev(".first").addClass("error")
			else
				additional.find("#current_credit").parent().removeClass("error")
				additional.find("#current_credit").parent().prev(".first").removeClass("error")

			reCalculate(so_nota.find("#nota_body_wrapper tr"), so_nota.find("#sub_total"), so_nota.find("#total_discount"), so_nota.find("#tax"), so_nota.find(".total_so"))
		so_nota.find("#nota_body_wrapper").niceScroll({touchbehavior:false,cursorcolor:"#e8eded",cursoropacitymax:1,cursorwidth:6})
		selectedSO()

	LoadSOSearch = (route)->
		if loadSOLock is 0
			loadSOLock = 1
			$table = $('.search_so')
			SOListUrl = route
			$table.html("")
			so_search_counter = 0
			so_current_search_position = -1

			$.get SOListUrl, (SO) ->		
				$.each SO, (index, list) ->
					row = $("<tr class='search_row' id="+list+"/>").append $("<td class='search_node' id='search_node_" + so_search_counter + "'/>").text(list)
					so_search_counter++
					$table.append row
			.done (->
				loadSOLock = 0
				$(".search_so").css("display", "block")

				if so_search_counter < 4
					$table.css("height",20*so_search_counter+"px")
				else
					$table.css("height",20*4+"px")

				$table.niceScroll({touchbehavior:false,cursorcolor:"#e8eded",cursoropacitymax:1,cursorwidth:6});
			)

	$('.salesOrder .title_text').on 'keypress', (event) ->
		if(event.keyCode < 48 || event.keyCode > 57)
			event.preventDefault()

	$(".salesOrder .title_text").on "input", (event) ->
		unless $(".salesOrder .title_text").val() is ""
			clearTimeout searchSOTimeout
			searchSOTimeout = setTimeout(->
			  LoadSOSearch("/SO/GetSOHeader/" + $(".salesOrder .title_text").val())
			  return
			, 500)

		else
			clearTimeout searchSOTimeout
			$('.search_so').scrollTop(0)
			$(".search_so").css("display", "none")
			so_current_search_position = -1

	$(".salesOrder .title_text").keydown (e) ->
		if $('.search_so').css('display') is 'block' 
			mouseover_so_enable = false
			if e.keyCode is 40
				e.preventDefault()
				if so_current_search_position < so_search_counter-1
					$('.search_so .search_node').removeClass('search_choose');
					so_current_search_position++
					$('.search_so #search_node_' + so_current_search_position).addClass('search_choose')
					$('.search_so').scrollTop(20*(so_current_search_position))
					
			else if e.keyCode is 38
				e.preventDefault()
				if so_current_search_position < 0
					so_current_search_position = 0

				if so_current_search_position > 0
					$('.search_so .search_node').removeClass('search_choose');
					so_current_search_position--
					$('.search_so #search_node_' + so_current_search_position).addClass('search_choose')
					
					if so_current_search_position < 3
						$('.search_so').scrollTop(0)
					else
						$('.search_so').scrollTop(20*(so_current_search_position-3))
			else if e.keyCode is 39 or e.keyCode is 13
				if so_current_search_position isnt -1
					e.preventDefault()
					clearTimeout searchSOTimeout
					$(".salesOrder .title_text").val($('.search_so #search_node_' + so_current_search_position).text())
					$('.search_so').scrollTop(0)
					$(".search_so").css("display", "none")
					$("#so_header_input").addClass("hide")
					$("#so_header_history").removeClass("hide")
					$("#so_additional_input").addClass("hide")
					$("#so_additional_history").removeClass("hide")
					$("#so_nota_input").addClass("hide")
					$("#so_nota_history").removeClass("hide")
					$("#approve_button_input").addClass("hide")
					$("#save_button_input").addClass("hide")
					$("#clear_button_input").addClass("hide")
					$("#so_error_input").addClass("hide")
					$("#so_success_input").addClass("hide")
					$("#so_error_history").removeClass("hide")
					$("#so_success_history").removeClass("hide")
					cur_SO = 0 #opening nota history
					LoadSObyID("/SO/GetSO/" + encodeURIComponent($('.search_so #search_node_' + so_current_search_position).text()))
					so_current_search_position = -1

	$(".salesOrder .title_text").focusout ->
		$('.search_so #search_node_' + so_current_search_position).removeClass('search_choose')

	$('.search_so').on 'click', '.search_node', (event) ->
		$(".salesOrder .title_text").val($('.search_so #search_node_' + so_current_search_position).text())
		$(".search_so").css("display", "none")
		$("#so_header_input").addClass("hide")
		$("#so_header_history").removeClass("hide")
		$("#so_additional_input").addClass("hide")
		$("#so_additional_history").removeClass("hide")
		$("#so_nota_input").addClass("hide")
		$("#so_nota_history").removeClass("hide")
		$("#approve_button_input").addClass("hide")
		$("#save_button_input").addClass("hide")
		$("#clear_button_input").addClass("hide")
		$("#so_error_input").addClass("hide")
		$("#so_success_input").addClass("hide")
		$("#so_error_history").removeClass("hide")
		$("#so_success_history").removeClass("hide")
		cur_SO = 0 #opening nota history
		LoadSObyID("/SO/GetSO/" + encodeURIComponent($('.search_so #search_node_' + so_current_search_position).text()))
		so_current_search_position = -1

	$('.search_so').on 'mouseover', '.search_node', (event) ->
		if mouseover_so_enable
			id_length = $(this).attr("id").length
			id_str = $(this).attr("id")
			so_current_search_position = id_str.substring(12,id_length)
			$('.search_so .search_node').removeClass('search_choose');
			$(this).addClass('search_choose')

	$('.salesOrder').on 'mousemove', (event) ->
		mouseover_so_enable = true

	addCommas = (nStr) ->
		nStr += ""
		x = nStr.split(".")
		
		if x.length is 1 #Jika tidak ada decimal point maka tambahkan
			nStr = x[0] + ".00"			
			x = nStr.split(".")
		
		x1 = x[0]
		x1 = x1.replace(/,/g,"")
		x2 = "." + x[1]
		rgx = /(\d+)(\d{3})/
		x1 = x1.replace(rgx, "$1" + "," + "$2")  while rgx.test(x1)
		return x1 + x2

	getCommas = (element) ->
		result = element.getSelectionAll(element.val().length).match(/,/g)
		if result is null
			return 0
		else
			return result.length

	toCurrency = (element, temp_counter)->
		cur_cursor = element.getCursorPosition()
		element.val(addCommas(element.val()))
		result = element.getSelectionAll(element.val().length).match(/,/g)
		if result is null
			element.setCursorPosition(cur_cursor)
			if(temp_counter == 1)
				element.setCursorPosition(cur_cursor - 1)
				temp_counter = 0
		else
			if(temp_counter > result.length)
				element.setCursorPosition(cur_cursor - 1)
			else if(temp_counter < result.length)
				element.setCursorPosition(cur_cursor + 1)
			else
				element.setCursorPosition(cur_cursor)
			temp_counter = result.length
		return temp_counter

	reCalculate = (table_parent_tr,sub_total,total_discount,tax,grand_total) ->
		#recalculate sub_total
		temp_sub_total = 0
		table_parent_tr.each ->
			temp_sub_total += Number($(this).find(".col_total").find("input").val().replace(/[^0-9\.-]+/g,""))
		sub_total.val(addCommas(parseFloat(temp_sub_total).toFixed(2)))
		discount_total = 0
		table_parent_tr.each ->
			if ($(this).find(".col_disc").find("input").val() is "")
				$(this).find(".col_disc").find("input").val(0)
			discount_total += (Number($(this).find(".col_disc").find("input").val())/100.0) * Number($(this).find(".col_total").find("input").val().replace(/[^0-9\.-]+/g,""))

		total_discount.val(addCommas(parseFloat(discount_total).toFixed(2)))
		#recalculate tax
		tax.val(addCommas(parseFloat(tax.data("tax") * (temp_sub_total-discount_total)).toFixed(2)))
		#recalculate discount
		reCalculateGrandTotal(grand_total)
		
	reCalculateGrandTotal = (id_parent)->
		#recalculate grand total
		sub_total = Number(id_parent.find('#sub_total').val().replace(/[^0-9\.-]+/g,""))
		discount = Number(id_parent.find('#total_discount').val().replace(/[^0-9\.-]+/g,""))
		tax = Number(id_parent.find('#tax').val().replace(/[^0-9\.-]+/g,""))
		handling = Number(id_parent.find('#handling').val().replace(/[^0-9\.-]+/g,""))
		grand_total = sub_total - discount + tax + handling
		id_parent.find('#grand_total').val(addCommas(parseFloat(grand_total).toFixed(2)))

		if SO_status < 20
			if cur_SO is 1
				id_selector = "#so_additional_input"
			else
				id_selector = "#so_additional_history"

			current_credit = Number($(id_selector).find("#current_credit").data("current_credit")) + grand_total

			if current_credit.toFixed(2) > Number($(id_selector).find("#credit_limit").val().replace(/[^0-9\.-]+/g,""))
				$(id_selector).find("#current_credit").parent().addClass("error")
				$(id_selector).find("#current_credit").parent().prev(".first").addClass("error")
			else
				$(id_selector).find("#current_credit").parent().removeClass("error")
				$(id_selector).find("#current_credit").parent().prev(".first").removeClass("error")

			$(id_selector).find("#current_credit").val(addCommas(current_credit))
			$(id_selector).find("#current_credit").attr("title", addCommas(current_credit))

	renameNotaElement = (element) ->
		inventory_to_nota = 0
		$(element).each ->
			$(this).find(".col_id").find("input").attr("name","products["+inventory_to_nota+"].product_id")
			$(this).find(".col_desc").find("input").attr("name","products["+inventory_to_nota+"].desc")
			$(this).find(".col_qty").find("input").attr("name","products["+inventory_to_nota+"].qty")
			$(this).find(".col_unit").find("select").attr("name","products["+inventory_to_nota+"].unit_multiplier")
			$(this).find(".col_unit").find("input").attr("name","products["+inventory_to_nota+"].unit_name")
			$(this).find(".col_price").find("input").attr("name","products["+inventory_to_nota+"].price")
			$(this).find(".col_disc").find("input").attr("name","products["+inventory_to_nota+"].discount")
			$(this).find(".col_total").find("input").attr("name","products["+inventory_to_nota+"].total")
			inventory_to_nota = inventory_to_nota + 1

	clearForm = (element) ->
		block1 = $("#so_header_"+ element)
		block1.find("#deliver_to_addr").val("")
		block1.find("#deliver_to_city").val("")

		$("#so_additional_"+ element).find("#sales_id").val()

		LoadCurrentDate('#so_additional_'+element+'', 30)

		block2 = $("#so_nota_"+ element)
		block2.find(".nota_body tbody").html("")
		block2.find("#sub_total").text("0.00")
		block2.find("#total_discount").text("0.00")
		block2.find("#tax").text("0.00")
		block2.find("#handling").val("0.00")
		block2.find("#grand_total").text("0.00")
		block2.find("textarea").val("")

	$("table.detail_header_nota_additional").on 'change', '#sales_id', (event) ->
		$(this).attr("title", $(this).find("option:selected").text())

	$("table.nota_body").on 'change', 'select', (event) ->
		$(this).next("input").val($(this).find("option:selected").text())

		priceElement = $(this).parent().siblings(".col_price").find("input")
		newPrice = (addCommas(priceElement.data("price") * $(this).val()))
		priceElement.val(newPrice)
		priceElement.attr("title", newPrice)

		price = Number(priceElement.val().replace(/[^0-9\.-]+/g,"")).toFixed(2)
		quantity = Number($(this).parent().siblings(".col_qty").find("input").val())
		
		total_price = Number(price * quantity).toFixed(2)
		$(this).parent().siblings(".col_total").find("input").val(addCommas(total_price))
		$(this).parent().siblings(".col_total").find("input").attr("title", addCommas(total_price))
		id_selector = '#' + $(this).parents(".main_nota").attr("id")
		reCalculate($(id_selector + ' #nota_body_wrapper tr'),$(id_selector + ' #sub_total'),$(id_selector + ' #total_discount'),$(id_selector + ' #tax'),$(id_selector + ' .total_so'))

	$("table.detail_header_nota_additional").on 'keypress', '#terms', (event) ->
		if(event.keyCode < 48 || event.keyCode > 57)
			event.preventDefault()

	$("table.detail_header_nota_additional").on 'input', '#terms', (event) ->
		days = Number($(this).val())
		id_selector = $(this).parents('table').prop('id')

		now = new Date($('#'+id_selector+' #so_date').val());
		now.setDate(now.getDate() + days);
		day = ("0" + now.getDate()).slice(-2)
		month = ("0" + (now.getMonth() + 1)).slice(-2)
		today = now.getFullYear()+"-"+(month)+"-"+(day)
		$('#'+id_selector+' #due_date').val(today)

	$("table.detail_header_nota_additional").on 'focusout', '#terms', (event) ->
		if $(this).val() is ""
			$(this).val(0)
			days = Number($(this).val())
			id_selector = $(this).parents('table').prop('id')

			now = new Date($('#'+id_selector+' #so_date').val());
			now.setDate(now.getDate() + days);
			day = ("0" + now.getDate()).slice(-2)
			month = ("0" + (now.getMonth() + 1)).slice(-2)
			today = now.getFullYear()+"-"+(month)+"-"+(day)
			$('#'+id_selector+' #due_date').val(today)

	$("table.detail_header_nota_additional").on 'change', '#due_date', (event) ->
		id_selector = $(this).parents('table').prop('id')
		date = new Date($('#'+id_selector+' #so_date').val())
		due_date  = new Date($(this).val())
		diff  = new Date(due_date - date)
		days  = Math.floor(diff/1000/60/60/24)

		$('#'+id_selector+' #terms').val(Number(days))

	$("table.detail_header_nota_additional").on 'change', '#so_date', (event) ->
		id_selector = $(this).parents('table').prop('id')
		$('#'+id_selector+' #due_date').prop('min', $(this).val())

		date = new Date($(this).val())
		due_date  = new Date($('#'+id_selector+' #due_date').val())
		diff  = new Date(due_date - date)
		days  = Math.floor(diff/1000/60/60/24)

		$('#'+id_selector+' #terms').val(Number(days))

	$('div.main_nota').on 'click','#nota_body_wrapper .col_remove', (event) ->
		id_selector = '#' + $(this).parents(".main_nota").attr("id")
		$(this).parent().remove()
		renameNotaElement(id_selector + ' #nota_body_wrapper tr')
		reCalculate($(id_selector + ' #nota_body_wrapper tr'),$(id_selector + ' #sub_total'),$(id_selector + ' #total_discount'),$(id_selector + ' #tax'),$(id_selector + ' .total_so'))
		
	$("div.main_nota").on 'keypress', '.col_price', (event) ->
		if(event.keyCode < 48 || event.keyCode > 57)
			event.preventDefault()

	$("div.main_nota").on 'input', '#nota_body_wrapper .col_price', (event) ->
		if $.isNumeric($(this).find("input").val().replace(/[^0-9\.-]+/g,""))
			commas_counter_price = toCurrency($(this).find('input'), getCommas($(this).find('input')))
		else
			$(this).find("input").val("0.00")
			$(this).find('input').setCursorPosition(0)

		$(this).find('input').attr("title", $(this).find('input').val())
		price = Number($(this).find("input").val().replace(/[^0-9\.-]+/g,"")).toFixed(2)
		quantity = Number($(this).siblings(".col_qty").find("input").val())
		total_price = Number(price * quantity).toFixed(2)
		$(this).siblings(".col_total").find("input").val(addCommas(total_price))
		$(this).siblings(".col_total").find("input").attr("title", addCommas(total_price))
		id_selector = '#' + $(this).parents(".main_nota").attr("id")
		reCalculate($(id_selector + ' #nota_body_wrapper tr'),$(id_selector + ' #sub_total'),$(id_selector + ' #total_discount'),$(id_selector + ' #tax'),$(id_selector + ' .total_so'))

	$('div.main_nota').on 'focusout','#nota_body_wrapper .col_price', (event) ->
		if not $.isNumeric($(this).find("input").val().replace(/[^0-9\.-]+/g,""))
			$(this).find("input").val("0.00")
			$(this).find('input').setCursorPosition(0)
			$(this).find('input').attr("title", $(this).find('input').val())
			$(this).siblings(".col_total").find("input").val("0.00")
			$(this).siblings(".col_total").find("input").attr("title", "0.00")
			id_selector = '#' + $(this).parents(".main_nota").attr("id")
			reCalculate($(id_selector + ' #nota_body_wrapper tr'),$(id_selector + ' #sub_total'),$(id_selector + ' #total_discount'),$(id_selector + ' #tax'),$(id_selector + ' .total_so'))

	$('div.main_nota').on 'keypress','#nota_body_wrapper .col_qty', (event) ->
		if(event.keyCode < 48 || event.keyCode > 57)
			event.preventDefault()

	$('div.main_nota').on 'input','#nota_body_wrapper .col_qty', (event) ->
		if $(this).find("input").val() isnt ""
			price = Number($(this).siblings(".col_price").find("input").val().replace(/[^0-9\.-]+/g,"")).toFixed(2)
			quantity = Number($(this).find("input").val())
			$(this).siblings(".col_total").find("input").val(addCommas(parseFloat(price * quantity).toFixed(2)))
			$(this).siblings(".col_total").find("input").attr("title", addCommas(parseFloat(price * quantity).toFixed(2)))
			id_selector = '#' + $(this).parents(".main_nota").attr("id")
			reCalculate($(id_selector + ' #nota_body_wrapper tr'),$(id_selector + ' #sub_total'),$(id_selector + ' #total_discount'),$(id_selector + ' #tax'),$(id_selector + ' .total_so'))

	$('div.main_nota').on 'focusout','#nota_body_wrapper .col_qty', (event) ->
		if $(this).find("input").val() is ""
			$(this).find("input").val(1)
			price = parseFloat($(this).siblings(".col_price").find("input").val().replace(/[^0-9\.-]+/g,"")).toFixed(2)
			$(this).siblings(".col_total").find("input").val(addCommas(price))
			$(this).siblings(".col_total").find("input").attr("title",addCommas(price))
			id_selector = '#' + $(this).parents(".main_nota").attr("id")
			reCalculate($(id_selector + ' #nota_body_wrapper tr'),$(id_selector + ' #sub_total'),$(id_selector + ' #total_discount'),$(id_selector + ' #tax'),$(id_selector + ' .total_so'))
	
	$('div.main_nota').on 'keypress','.col_disc', (event) ->
		if(event.keyCode < 48 || event.keyCode > 57)
			event.preventDefault()
		
	$('div.main_nota').on 'input','.col_disc', (event) ->
		if $(this).find("input").val() isnt ""
			discount = Number($(this).find("input").val())
			if(discount > 100)
				$(this).find("input").val(100)
			id_selector = '#' + $(this).parents(".main_nota").attr("id")
			reCalculate($(id_selector + ' #nota_body_wrapper tr'),$(id_selector + ' #sub_total'),$(id_selector + ' #total_discount'),$(id_selector + ' #tax'),$(id_selector + ' .total_so'))

	$('div.main_nota').on 'focusout','.col_disc', (event) ->
		if $(this).find("input").val() is ""
			$(this).find("input").val(0)
			id_selector = '#' + $(this).parents(".main_nota").attr("id")
			reCalculate($(id_selector + ' #nota_body_wrapper tr'),$(id_selector + ' #sub_total'),$(id_selector + ' #total_discount'),$(id_selector + ' #tax'),$(id_selector + ' .total_so'))

	$('div.main_nota').on 'keypress','.total_so #handling', (event) ->
		if(event.keyCode < 48 || event.keyCode > 57)
			event.preventDefault()

	last_result_handling = 0
	$('div.main_nota').on 'input','.total_so #handling', (event) ->
		if $(this).val() isnt ""
			last_result_handling = toCurrency($(this), last_result_handling)
			id_selector = '#' + $(this).parents(".main_nota").attr("id")
			reCalculateGrandTotal($(id_selector + ' .total_so'))

	$('div.main_nota').on 'focusout','.total_so #handling', (event) ->
		if $(this).val() is ""
			$(this).val("0.00")
			last_result_handling = "0.00"
			id_selector = '#' + $(this).parents(".main_nota").attr("id")
			reCalculateGrandTotal($(id_selector + ' .total_so'))

	continue_form = false
	resubmit_form = (selected_button) ->
		continue_form = true
		$("#"+selected_button).trigger("click")

	$('.salesOrder').on 'click', '#save_button_input, #save_button_history', (event) ->
		if $(this).attr("id") is "save_button_input"
			element = "input"
		else if $(this).attr("id") is "save_button_history"
			element = "history"

		id_selector = "#so_nota_" +element
		id_selector1 = "#so_additional_" +element

		if $(id_selector + " #nota_body_wrapper .nota_body tbody").html() isnt "" and continue_form is false
			if $(id_selector1 + " #so_date").val() isnt "" and $(id_selector1 + " #due_date").val() isnt ""
				selected_button = $(this).attr("id")
				if($(this).val() is "Save")
					$.prompt "Are you sure you want to SAVE this note?",
						title: "WARNING"
						buttons:
							"Continue": true
							"Cancel": false
						submit: (e, v, m, f) ->
							if v is true
								resubmit_form(selected_button)
				else
					$.prompt "Are you sure you want to REJECT this note?",
						title: "WARNING"
						buttons:
							"Continue": true
							"Cancel": false
						submit: (e, v, m, f) ->
							if v is true
								resubmit_form(selected_button)
				return false
			else
				$.prompt "SO/Due Date Not Inputted"
				return false
		else if continue_form is true
			return true
		else
			$.prompt "No Item Inputted"
			return false

	$('.salesOrder').on 'click', '#approve_button_input, #approve_button_history', (event) ->
		if $(this).attr("id") is "approve_button_input"
			element = "input"
		else if $(this).attr("id") is "approve_button_history"
			element = "history"

		id_selector = "#so_nota_" +element
		id_selector1 = "#so_additional_" +element

		current_credit = Number($(id_selector1).find("#current_credit").data("current_credit")) + Number($(id_selector).find("#grand_total").val().replace(/[^0-9\.-]+/g,""))

		if (current_credit > Number($(id_selector1).find("#credit_limit").val().replace(/[^0-9\.-]+/g,""))) and !permission_approve
			$.prompt "Credit Limit Exceeded"
			return false

		if $(id_selector + " #nota_body_wrapper .nota_body tbody").html() isnt "" and continue_form is false
			selected_button = $(this).attr("id")
			if $(id_selector1 + " #so_date").val() isnt "" and $(id_selector1 + " #due_date").val() isnt ""
				$.prompt "Are you sure you want to APPROVE this note?",
					title: "WARNING"
					buttons:
						"Continue": true
						"Cancel": false
					submit: (e, v, m, f) ->
						if v is true
							resubmit_form(selected_button)
				return false
			else
				$.prompt "SO/Due Date Not Inputted"
				return false
		else if continue_form is true
			return true
		else
			$.prompt "No Item Inputted"
			return false

	$('.salesOrder').on 'click', '#clear_button_input, #clear_button_history',(event) ->
		id_selector = $(this).attr("id")
		$.prompt "This Action will clear this SO form, continue?",
			title: "WARNING"
			buttons:
				"Continue": true
				"Cancel": false
			submit: (e, v, m, f) ->
				if v is true
					$('#so_search_bar').val("")
					if id_selector is "clear_button_input"
						clearForm("input")
					else if id_selector is "clear_button_history"
						clearForm("history")

	$('.nav_list').on 'click', '#nav_cr', (event) ->
		$("#so_header_history").addClass("hide")
		$("#so_header_input").removeClass("hide")
		$("#so_additional_history").addClass("hide")
		$("#so_additional_input").removeClass("hide")
		$("#so_nota_history").addClass("hide")
		$("#so_nota_input").removeClass("hide")

		$("#approve_button_input").removeClass("hide")
		$("#save_button_input").removeClass("hide")
		$("#clear_button_input").removeClass("hide")
		$("#approve_button_history").addClass("hide")
		$("#save_button_history").addClass("hide")
		$("#clear_button_history").addClass("hide")
		$(".salesOrder .title_text").val("")
		$("#so_error_input").removeClass("hide")
		$("#so_success_input").removeClass("hide")
		$("#so_error_history").addClass("hide")
		$("#so_success_history").addClass("hide")

		if $("#so_header_input #customer_id").val() is ""
			$(".customers .info").find("input").data("id", "")
			$(".customers .info").find("input").val("")
			$(".customers .info").find(".street").text("Street Address")
			$(".customers .info").find(".city").text("City")
			$(".customers .info").find(".province").text("Province")
			$(".customers .photo").attr("src", "/assets/images/customer.png")

			$("#sales_order").css("display","block")
			$("#inventory").css("display","none")
			$("#inventory_nav").addClass("hide")

			$(".SalesOrders .nav_list ul div li").each ->
				if $(this).find("a").attr("id") isnt "nav_cr"
					$(this).remove()

			$('.SalesOrders .nav_list ul div').css("height", "62px")

			LoadSOHistory('/SO/GetAllSOHistory')
		else
			if $(".customers .info").find("input").data("id") isnt $("#so_header_input").find("#customer_id").val()
				LoadCustomerDetails1("/SO/GetCustomerDetail/" + encodeURIComponent($("#so_header_input").find("#customer_id").val()), "input")

		$("#del_record").parent().addClass("hide")
		$(".nav_list-2").css("top", "660px")
		cur_SO = 1 #opening current SO

	$('.nav_list').on 'click', '.nav_node', (event) ->
		$("#so_header_input").addClass("hide")
		$("#so_header_history").removeClass("hide")
		$("#so_additional_input").addClass("hide")
		$("#so_additional_history").removeClass("hide")
		$("#so_nota_input").addClass("hide")
		$("#so_nota_history").removeClass("hide")
		$("#approve_button_input").addClass("hide")
		$("#save_button_input").addClass("hide")
		$("#clear_button_input").addClass("hide")
		$("#so_error_input").addClass("hide")
		$("#so_success_input").addClass("hide")
		$("#so_error_history").removeClass("hide")
		$("#so_success_history").removeClass("hide")
		cur_SO = 0 #opening PO history
		LoadSObyID("/SO/GetSO/" + $(this).attr("id"))

	DeleteRecord = (action, method, input) ->
	    "use strict"
	    form = undefined
	    form = $("<form />",
	        action: action
	        method: method
	        style: "display: none;"
	    )
	    if typeof input isnt "undefined"
	        $.each input, (name, value) ->
	            $("<input />",
	                type: "hidden"
	                name: name
	                value: value
	            ).appendTo form
	            return
	    form.appendTo("body").submit()

	$('#del_record').on 'click', (event) ->
		if SO_status is 0 or SO_status is 10
			so_id = $("#so_additional_history #so_id").val()

			$.prompt "Do you want to remove this SO from database ?",
				title: "WARNING"
				buttons:
					"Continue": true
					"Cancel": false
				submit: (e, v, m, f) ->
					if v is true
						DeleteRecord("/SO/Delete", 'post', {
							so_id:  encodeURIComponent(so_id)
						})
		else
			$.prompt("You cannot delete this SO.")

	if $('.SalesOrders .nav_list ul div li').length > 6
		$('.SalesOrders .nav_list ul div').css("overflow","hidden")
		$('.SalesOrders .nav_list ul div').css("height","382px")

	scrollValNota = 64
	counterNota = 0
	#default min ada 6 nota yang ditampilkan, else scroll
	$('.SalesOrders .nav_list ul #up').on 'click', (event) ->
		if maxNota > 0 && counterNota > 0
			counterNota--
			$('.SalesOrders .nav_list ul div').stop().animate({scrollTop: scrollValNota * counterNota},"slow")

	$('.SalesOrders .nav_list ul #down').on 'click', (event) ->
		if maxNota > 0 && counterNota < maxNota
			counterNota++
			$('.SalesOrders .nav_list ul div').stop().animate({scrollTop: scrollValNota * counterNota},"slow")

	# @SALES_ORDER | END #######
	
	$("#print").click ->
		$(".printpage").removeClass("hide")
		
		val1_1 = $("#so_header_history #customer_id").val()
		val1_2 = $("#so_header_history #deliver_to_addr").val()
		val1_3 = $("#so_header_history #submitted_id").val()
		val2_1 = $("#so_header_history #customer_name").text()
		val2_2 = $("#so_header_history #deliver_to_city").val()
		val2_3 = $("#so_header_history #edited_id").val()
		val3_1 = $("#so_header_history #customer_addr").text()
		
		add1_1 = $("#so_additional_history #so_id").val()
		
		temp1_2 = $("#so_additional_history #due_date").val().split("-")
		newTemp1_2 = temp1_2[1]+"/"+temp1_2[2]+"/"+temp1_2[0]
		add1_2 = getDate(new Date(newTemp1_2).getTime())
		
		add1_3 = $("#so_additional_history #tax_number").val()
		add1_4 = $("#so_additional_history #credit_limit").val()
		
		temp2_1 = $("#so_additional_history #so_date").val().split("-")
		newTemp2_1 = temp2_1[1]+"/"+temp2_1[2]+"/"+temp2_1[0]
		add2_1 = getDate(new Date(newTemp2_1).getTime())
		
		add2_2 = $("#so_additional_history #terms").val()
		add2_3 = $("#so_additional_history #sales_id").val()
		add2_4 = $("#so_additional_history #current_credit").val()
		
		subtotal = $("#so_nota_history #sub_total").val()
		disc = $("#so_nota_history #total_discount").val()
		tax = $("#so_nota_history #tax").val()
		handling = $("#so_nota_history #handling").val()
		grandtotal = $("#so_nota_history #grand_total").val()
		termncond = $("#terms_and_cond").val()
		addnote = $("#additional_note").val()

		barcode = "/GenerateBarcode/"+add1_1
		
		getPrintDate = (timestamp)->
			monthNames = [
			  "January"
			  "February"
			  "March"
			  "April"
			  "May"
			  "June"
			  "July"
			  "August"
			  "September"
			  "October"
			  "November"
			  "December"
			]
			currentdate = new Date(timestamp)
			if currentdate.getDate() < 10
				dates = "0" + currentdate.getDate()  
			else
				dates = currentdate.getDate()
			datetime = dates + " " + (monthNames[currentdate.getMonth()])  + " " + currentdate.getFullYear()

		
		tt = getPrintDate(new Date().getTime())
		foot_head1= "Banjarmasin, " + tt
  
		pg = 1
		pagename = "page-"+pg
		tablename = "table"+pg
		pageof = "pageof-"+pg
		c = 0
		cal_height = 0
		headcon = (pg) ->
			pagename = "page-"+pg
			tablename = "table"+pg
			pageof = "pageof-"+pg
			
			return "<div class='print' id='"+pagename+"'> \
			<div class='print_content'> \
			<img class='print_barcode' src='"+barcode+"'/> \
			<div class='print_header'> \
			<img class='print_header_content_photo'/> \
			<div class='print_header_content_desc'> \
			<div class='print_header_content_desc_h'>PT. Aneka Mekar</div> \
			<div class='print_header_content_desc_p1'>Jl. Gatot Subroto No. 67, Banjarmasin-Kalimantan Selatan 8117</div> \
			<div class='print_header_content_desc_p2'>Phone : +62 9836 2223 | E-mail : vorszavorsz.com | Website : vorsz.com</div> \
			</div> \
			<div class='print_header_content_detail'> \
			<div class='print_header_content_detail_h'>SALES ORDER</div> \
			<div class='print_header_content_detail_p' id='"+pageof+"'></div> \
			</div> \
			</div> \
			<div class='print_body'> \
			<div class='print_body_header'> \
			<table class='print_body_header_detail'> \
			<tr> \
			<td class='first'>Sales To</td> \
			<td class='colon'>:</td> \
			<td class='second'>"+val1_1+"</td> \
			<td class='first'>Deliver to addr</td> \
			<td class='colon'>:</td> \
			<td class='second'>"+val1_2+"</td> \
			<td class='first'>Submitted By</td> \
			<td class='colon'>:</td> \
			<td class='second'>"+val1_3+"</td> \
			</tr> \
			<tr> \
			<td class='first'>&nbsp;</td> \
			<td class='colon'>&nbsp;</td> \
			<td class='second'>"+val2_1+"</td> \
			<td class='first'>Deliver to city</td> \
			<td class='colon'>:</td> \
			<td class='second'>"+val2_2+"</td> \
			<td class='first'>Last Edited By</td> \
			<td class='colon'>:</td> \
			<td class='second'>"+val2_3+"</td> \				
			</tr> \
			<tr> \
			<td class='first'>&nbsp;</td> \
			<td class='colon'>&nbsp;</td> \
			<td class='second'>"+val3_1+"</td> \
			<td class='first'>&nbsp;</td> \
			<td class='colon'>&nbsp;</td> \
			<td class='second'>&nbsp;</td> \
			<td class='first'>&nbsp;</td> \
			<td class='colon'>&nbsp;</td> \
			<td class='second'>&nbsp;</td> \
			</tr> \
			</table> \
			<table class='print_body_header_additional'> \
			<tr> \
			<td class='first'>SO Number</td> \
			<td class='second'>"+add1_1+"</td> \
			<td class='first'>Due Date</td> \
			<td class='second'>"+add1_2+"</td> \
			<td class='first'>Tax Number</td> \
			<td class='second'>"+add1_3+"</td> \
			<td class='first'>Credit Limit</td> \
			<td class='second'>"+add1_4+"</td> \
			</tr> \
			<tr> \
			<td class='first'>SO Date</td> \
			<td class='second'>"+add2_1+"</td> \
			<td class='first'>Terms</td> \
			<td class='second'>"+add2_2+"</td> \
			<td class='first'>KDSR</td> \
			<td class='second'>"+add2_3+"</td> \
			<td class='first'>Current Credit</td> \
			<td class='second'>"+add2_4+"</td> \
			</tr> \
			<tr> \
			<td class='three'></td> \
			</tr> \
			</table> \
			</div> \
			<div class='print_body_content' id='"+tablename+"'> \					
			</div> \
			</div> \
			</div> \
			</div>"
		
		tabheader = () ->
			return "<div class='main_table_head'> \
			<div class='col_1'><div class='spans'>ID</div></div> \
			<div class='col_2'><div class='spans'>Description</div></div> \
			<div class='col_3'><div class='spans'>QTY</div></div> \
			<div class='col_4'><div class='spans'>Unit</div></div> \
			<div class='col_5'><div class='spans'>Price (IDR)</div></div> \
			<div class='col_6'><div class='spans'>Disc (%)</div></div> \
			<div class='col_7'><div class='spans'>Total (IDR)</div></div> \
			<div class='col_8'><div class='spans'>Con.</div></div> \
			</div>"
		
		$('.printpage').append(headcon(pg))
		$("#"+tablename).append(tabheader())
		
					
		$("#so_nota_history .nota_body tr").each ->
			if $(this).find(".col_contract").find("input").is(':checked') is true
				chk = "<div class='checked'></div>"
			else
				chk = "<div class='uncheck'></div>"
			
			$("#"+tablename).append("<div class='main_table_content'> \
			<div class='col_1'><div class='spans'>"+$(this).find(".col_id").find("input").val()+"</div></div> \
			<div class='col_2'><div class='spans'>"+$(this).find(".desc_history").find("input").val()+"</div></div> \
			<div class='col_3'><div class='spans'>"+$(this).find(".col_qty").find("input").val()+"</div></div> \
			<div class='col_4'><div class='spans'>"+$(this).find(".col_unit").find("input").val()+"</div></div> \
			<div class='col_5'><div class='spans'>"+$(this).find(".col_price").find("input").val()+"</div></div> \
			<div class='col_6'><div class='spans'>"+$(this).find(".col_disc").find("input").val()+"</div></div> \
			<div class='col_7'><div class='spans'>"+$(this).find(".col_total").find("input").val()+"</div></div> \
			<div class='col_8'>"+chk+"</div> \
			</div>")
					
			cal_height += $(".main_table_content").last().height()
			
			if(cal_height > 1125)
				cal_height = 0
				html = $(".main_table_content").last().html()
				$(".main_table_content").last().remove()
				pg++
				$('.printpage').append(headcon(pg))	
				$("#"+tablename).append(tabheader())
				
				$("#"+tablename).append("<div class='main_table_content'>"+html+"</div>")
				cal_height += $(".main_table_content").height()
				
			
		#	#testing
		#	for j in [1..(15)] by 1
		#		$("#"+tablename).append("<div class='main_table_content'> \
		#		<div class='col_1'><div class='spans'>"+$(this).find(".col_id").find("input").val()+"</div></div> \
		#		<div class='col_2'><div class='spans'>"+$(this).find(".col_desc").find("input").val()+"</div></div> \
		#		<div class='col_3'><div class='spans'>"+$(this).find(".col_qty").find("input").val()+"</div></div> \
		#		<div class='col_4'><div class='spans'>"+$(this).find(".col_price").find("input").val()+"</div></div> \
		#		<div class='col_5'><div class='spans'>"+$(this).find(".col_disc").find("input").val()+"</div></div> \
	    #        <div class='col_6'><div class='spans'>"+$(this).find(".col_total").find("input").val()+"</div></div> \
		#		</div>")
		#				
		#		cal_height += $(".main_table_content").last().height()
		#		
		#		if(cal_height > 1125)
		#			cal_height = 0
		#			html = $(".main_table_content").last().html()
		#			$(".main_table_content").last().remove()
		#			pg++
		#			$('.printpage').append(headcon(pg))	
		#			$("#"+tablename).append(tabheader())
		#			
		#			$("#"+tablename).append("<div class='main_table_content'>"+html+"</div>")
		#			cal_height += $(".main_table_content").height()
		#	#endtesting
		
		if(cal_height > 675)
			pg++
			$('.printpage').append(headcon(pg))	
			$("#"+tablename).addClass("hide")
	
		$(".print_body").last().append("<div class='print_body_footer'> \
		<div class='print_body_footer_content_detail'> \
		<div class='print_body_footer_content_detail_1'> \
		<div class='print_body_footer_content_detail_head'>Additional Note</div> \
		<div class='print_body_footer_content_detail_value'> \
		"+addnote+"
		</div> \
		</div> \
		<div class='print_body_footer_content_detail_2'> \
		<div class='print_body_footer_content_detail_head'>Terms & Condition</div> \
		<div class='print_body_footer_content_detail_value'> \
		"+termncond+"
		</div> \
		</div> \
		</div> \
		<div class='print_body_footer_content_money'> \
		<div class='print_body_footer_content_money_1'>Sub Total (IDR)</div> \
		<div class='print_body_footer_content_money_2'>"+subtotal+"</div> \
		<div class='print_body_footer_content_money_1'>Discount (%)</div> \
		<div class='print_body_footer_content_money_2'>"+disc+"</div> \
		<div class='print_body_footer_content_money_1'>Tax (%)</div> \
		<div class='print_body_footer_content_money_2'>"+tax+"</div> \
		<div class='print_body_footer_content_money_1'>Handling (IDR)</div> \
		<div class='print_body_footer_content_money_2'>"+handling+"</div> \
		<div class='print_body_footer_content_money_3'></div> \
		<div class='print_body_footer_content_money_1_bold'>Grand Total (IDR)</div> \
		<div class='print_body_footer_content_money_2_bold'>"+grandtotal+"</div> \
		</div> \
		</div>")
		
		$(".print_content").last().append("<div class='print_footer'> \
		<div class='print_footer_content_1'>"+foot_head1+"</div> \
		<div class='print_footer_content_1'></div> \
		<div class='print_footer_content_1'></div> \
		<div class='print_footer_content_2'></div> \
		<div class='print_footer_content_2'></div> \
		<div class='print_footer_content_2'></div> \
		<div class='print_footer_content_3'>( ________________________ )</div> \
		<div class='print_footer_content_3'></div> \
		<div class='print_footer_content_3'></div> \
		</div>")
		
		for j in [1..(pg)] by 1
			temppage = "pageof-"+j
			temp = "Page " + j + " of " + pg
			$("#"+temppage).append(""+temp+"")
			
		#window.setTimeout (->
		window.print()
		$(".printpage").html("")
		$(".printpage").addClass("hide")
		#	return
		#), 500