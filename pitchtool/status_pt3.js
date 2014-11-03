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
   
   d3.json('getStatus_pt3.xql', function(error, json) {
      if (error) return console.warn(error);
      
      data = json;
      console.log(data);
      
      d3.select('#results').selectAll('div')
            .data(data.sources)
            .enter()
            .append('div')
            .classed('source',true)
            .append('h4')
            .text(function(d) {return d.label;});
            
      d3.selectAll('#results div')
            .selectAll('div.mov')
            .data(function(d) {return d.movements})
            .enter()
            .append('div').classed('movContainer', true).attr('title', function(d) {return d.label;})
            .append('h5')
              .text(function(d) {return d.label;});
              
      d3.selectAll('div.movContainer')
            .append('div').classed('measureBar', true)
              .classed('mov',true)
            .selectAll('span.page')
            .data(function(d) {return d.pages})
            .enter()
            .append('span')
            .classed('mov',true)
            .classed('page', true)
            .classed('filled',true)
/*            .classed('checked', function(d){return d.checked})*/
            .attr('title',function(d){return d.name + ' (' + d.measures + ' measures)'})
            .style('width',function(d){return d.measures * 2 + 'px'})
/*            .style('background',function(d){return "-linear-gradient(rgba(255,170,0,0.4)" + function(d){return 100 - d.checked*100 + '%'} + ", rgba(100,255,0,0.4) " + function(d){return d.checked*100 + '%'} + ")"})*/
            .append('span')
            .classed('checked', true)
            .classed('pageStatus', true)
            .style('width',function(d){return d.checked*100 + '%'})
            .text(' ')
            ;
            
            
/*      d3.selectAll('#results div div div.mov')*/
/*            .data(function(d) {return d.pages;})*/
/*            .append('span')*/
            /*
            .data(function(d) {return d.pages})
            .append('span')
            .classed('filled',function(d){return d.filled})
            .classed('unfilled',function(d){return !d.filled})
            .attr('title',function(d){return d.label + ' (' + d.measures + ' measures)'})
            .style('width',function(d){return d.measures/3.5 + 'px'});
      d3.selectAll('#results div.source')
            .append('span')
            .classed('label label-inverse',true)
            .text(function(d) {return d.measures + ' measures'});*/
            //.text(function(d) {return d.label + ': Sätze: ' + d.movements.length});
   });
};

getStatus();