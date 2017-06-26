var margin = { top: 20, bottom: 40, left: 40, right: 20 };

var outerWidth = 800,
    outerHeight = 400,
    width = outerWidth - margin.left - margin.right,
    height = outerHeight - margin.top - margin.bottom;
    y_max = 200; // hard-coded because the data is suspect

// chart elements: axes (v4) ----------
var x_scale = d3.scaleTime().range([0, width]);
var y_scale = d3.scaleLinear().range([height, 0]);

var parseTime = d3.timeParse("%Y-%m-%d %H:%M:%S"); //.%L"); //%L is microseconds
//-------------------------------------

Shiny.addCustomMessageHandler("purdue_coord",
    function(message){

        var data = JSON.parse(message); // message is text, data is an object

        //alert(message);
        
        d3.selectAll(".plot1").remove();

        // parse the data fields
        data.forEach(function(d) {
            d.Timestamp = parseTime(d.TimeStamp);
            d.GreenTime = +d.GreenTime;
            d.YellowTime = +d.YellowTime;
            d.RedTime = +d.RedTime;
            d.CycleTime = +d.GreenTime + d.YellowTime + d.RedTime;
        });

        // define the axes
        //var y_max = d3.max(data, function(d) { return d.Duration; });
        x_scale.domain(d3.extent(data, function(d) { 
            return d.Timestamp; 
        })).nice();
        y_scale.domain([0, y_max]).nice();

        // nest the data by EventParam (Phase)
        var chart_data = d3.nest()
            .key(function(d) { 
                return d.EventParam; 
            }).sortKeys(d3.ascending)
            .entries(data);
        //alert(JSON.stringify(chart_data[0])); // debug step
        // create chart multiples
        var svg = d3.select("#plots").selectAll("svg")
                .data(chart_data)
            .enter().append("svg")
                .attr("class", "plot1")
                .attr("viewBox", "0 0 " + outerWidth + " " 
                                        + outerHeight + "")
                .attr("width", outerWidth)
                .attr("height", outerHeight)
            .append("g")
                .attr("class", "chart1")
                .attr("transform", "translate(" + margin.left + ", " 
                                                + margin.top + ")")
                .each(draw_chart); // each
    });

    function draw_chart(phase) { //, y_max) {

        var stack = d3.stack().keys(["GreenTime",
                                     "YellowTime",
                                     "RedTime"]),
            colors = ["rgb(100,255,100)",
                      "rgb(255,255,100)",
                      "rgb(255,100,100)"],
            select_colors = ["rgb(0,150,0)",
                             "rgb(150,150,0)",
                             "rgb(150,0,0)"],
            time = phase.values.map(function(d) { 
                return d.Timestamp; 
            }),
            cycle_time = phase.values.map(function(d) { 
                return d.CycleTime; 
            });
            
            var chart = d3.select(this);

        chart.append("g")
            .attr("class", "x axis")
            .attr("transform", "translate(0, " + height + ")")
            .call(d3.axisBottom(x_scale));

        chart.append("g")
            .attr("class", "y axis")
            .attr("transform", "translate(0,0)")
            .call(d3.axisLeft(y_scale));

        var groups = chart.selectAll("g.cost")
            .data(stack(phase.values))
            .enter().append("g")
                .attr("class", "cost")
                .attr("id", function(d,i) {
                    return i;
                })
                .style("fill", function(d,i) { 
                    return colors[i]; 
                });

        var rect = groups.selectAll("rect")
            .data(function(d) { 
                return d; 
            })
            .enter().append("rect") //.merge(rect) // merge is new
                .attr("x", function(d,i) { 
                    return x_scale(time[i]); 
                })
                .attr("width", function(d,i) { 
                    return x_scale(d3.timeSecond.offset(time[i], 
                                   cycle_time[i])) - x_scale(time[i]); 
                })
                .attr("y", function(d) { 
                    return y_scale(d[1]); 
                })
                .attr("height", function(d) { 
                    return y_scale(d[0]) - y_scale(d[1]); 
                })
                .on("mouseover", function(d,i) { 
                    d3.select(this).style("fill", function() {
                        return "" + select_colors[this.parentNode.id] + "";
                    });
                })
                .on("mouseout", function(d,i) { 
                    d3.select(this).style("fill", function() {
                        return "" + colors[this.parentNode.id] + "";
                    });
                });
        //rect.exit().remove(); // exit.remove is new
                

        // Add a small label for the symbol name.
         chart.append("text")
            .attr("x", 6)
            .attr("y", 6)
            .text(function(d) { return "Phase " + d.key; });
    }

