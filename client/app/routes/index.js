import Ember from 'ember';
import KeyboardShortcuts from 'ember-keyboard-shortcuts/mixins/route';

export default Ember.Route.extend(KeyboardShortcuts,{
  model() {
    return this.store.findAll('folder');
  },

  keyboardShortcuts: {
    'h' : 'previousFeed',
    'j' : 'previousItem',
    'k' : 'nextItem',
    'l' : 'nextFeed',
  },

  flatList: function() {
    var flatlist = ['items', 'favorites'];
    this.currentModel.forEach(function(folder) {
      flatlist.push(folder);
      if(folder.get('open')) {
        folder.get('feeds').forEach(function(feed) {
          flatlist.push(feed);
        });
      }
    });
    return flatlist;
  }.property('currentModel.@each.open', 'currentModel.@each.feeds'),

  actions: {
    previousFeed() {
      var selected = this.controller.get('selectedElement');
      var flatlist = this.get('flatList');
      var nextElement = flatlist[flatlist.indexOf(selected)-1];
      if(nextElement) {
        this.controller.send('selectModel', nextElement);
      }
    },

    previousItem() {
    },

    nextItem() {
    },

    nextFeed() {
      var selected = this.controller.get('selectedElement');
      var flatlist = this.get('flatList');
      var nextElement = flatlist[flatlist.indexOf(selected)+1];
      if(nextElement) {
        this.controller.send('selectModel', nextElement);
      }
    }
  }

});
