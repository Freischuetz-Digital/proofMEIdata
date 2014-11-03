function getStatus() {
    
    /*new jQuery.ajax('resources/xql/getStatus.xql', {
       method: 'get',
       //parameters: {meter: meter},
       success: function(result) {
          var response = result || '';
          
          var dataset = response;
          //console.log(response);
          //d3.select('#results').append('p').text('new paragraph!');
          d3.select('#results').selectAll('p').data(dataset).enter().append('p').text('new paragraph!');
       }   
   }); */
   
   d3.json('getStatus.xql', function(error, json) {
      if (error) return console.warn(error);
      
      data = json;
      console.log(data);
      
      d3.select('#results').selectAll('div')
            .data(data.sources)
            .enter()
            .append('div')
            .classed('source',true)
            .append('h5')
            .text(function(d) {return d.label;});
      d3.selectAll('#results div')
            .append('div').attr('class','measureBar')
            .selectAll('span.mov')
            .data(function(d) {return d.movements})
            .enter()
            .append('span')
            .classed('mov',true)
            .classed('filled',function(d){return d.filled})
            .classed('unfilled',function(d){return !d.filled})
            .attr('title',function(d){return d.label + ' (' + d.measures + ' measures)'})
            .style('width',function(d){return d.measures/3.5 + 'px'});
      d3.selectAll('#results div.source')
            .append('span')
            .classed('label label-inverse',true)
            .text(function(d) {return d.measures + ' measures'});
            //.text(function(d) {return d.label + ': Sätze: ' + d.movements.length});
   });
};

getStatus();