var colnames = Object.keys(data[0]);

data = JSON.parse(JSON.stringify(data).split('"' + colnames[0]+'":').join('"name":')); // name

data = JSON.parse(JSON.stringify(data).split('"' + colnames[1]+'":').join('"x":')); // x

data = JSON.parse(JSON.stringify(data).split('"' + colnames[2]+'":').join('"y":')); // y

     
// axis title variables     
   var yaxistext = "Y"
   
   var xaxistext = "X" 
     

// alternative way - iterate this through whole array.
// data[0].name = data[0][colnames[0]];
// delete data[0][colnames[0]];   
   
   
// setup   
     
    var margin = {top: 33, right: 5, bottom: 50, left: 50},
	    width = 450 - margin.left - margin.right,
	    height = 500 - margin.top - margin.bottom;

	  var svg = d3.select(".chart").append("svg")
	      .attr("width", width + margin.left + margin.right)
	      .attr("height", height + margin.top + margin.bottom)
	      .append("g")
	      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

	  var x = d3.scaleLinear()
	      .range([0,width]);

	  var y = d3.scaleLinear()
	      .range([height,0]);

	  var xAxis = d3.axisBottom()
	      .scale(x);

	  var yAxis = d3.axisLeft()
	      .scale(y);

      
      
// add basic axes, all points, calculate scales     

      y.domain(d3.extent(data, function(d){ return d.y}));
	    x.domain(d3.extent(data, function(d){ return d.x}));
      
      
	    svg.append("g")
	        .attr("class", "x axis")
	        .attr("transform", "translate(0," + height + ")")
	        .call(xAxis);

	    svg.append("g")
	        .attr("class", "y axis")
	        .call(yAxis);
	        
	   var tooltip = d3.select(".chart").append("div")
                  .attr("class", "tooltip")
                  .style("opacity", 0);
    
    var tipMouseover = function(d) {
                  var html  = d.name + "<br/>";
                  tooltip.html(html)
                      .style("left", (d3.event.pageX + 15) + "px")
                      .style("top", (d3.event.pageY - 28) + "px")
                    .transition()
                      .duration(200) // ms
                      .style("opacity", .9) // started as 0!

              };  
                  
        var tipMouseout = function(d) {
                  tooltip.transition()
                      .duration(300) // ms
                      .style("opacity", 0); // don't care about position!
              };            

	    svg.selectAll(".point")
	        .data(data)
	      .enter().append("circle")
	        .attr("class", "point")
	        .attr("r", 4)
	        .attr("cy", function(d){ return y(d.y); })
	        .attr("cx", function(d){ return x(d.x); })
	        .on("mouseover", tipMouseover)
          .on("mouseout", tipMouseout);
       
   
      
            
// text label for the x axis
// text label for the x axis
  svg.append("text")
      .attr("class", "axistext")
      .attr("transform",
            "translate(" + (width - margin.left) + " ," + 
                           (height + margin.top) + ")")
      .style("text-anchor", "right")
      .text(xaxistext);


// text label for the y axis
  svg.append("text")
      .attr("class", "axistext")
      .attr("transform", "rotate(-90)")
      .attr("y", 0 - margin.left)
      .attr("x",0 - (height/2))
      .attr("dy", "1em")
      .style("text-anchor", "middle")
      .text(yaxistext);  
      

      
      


      
  