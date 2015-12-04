import Ember from 'ember';
import KeyboardShortcuts from 'ember-keyboard-shortcuts/mixins/route';

export default Ember.Route.extend(KeyboardShortcuts,{
  model() {
    return this.store.findAll('folder');
  },

  keyboardShortcuts: {
    'h' : 'previousFeed',
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
        this.send('selectFeed', nextElement);
      }
    },

    nextFeed() {
      var selected = this.controller.get('selectedElement');
      var flatlist = this.get('flatList');
      var nextElement = flatlist[flatlist.indexOf(selected)+1];
      if(nextElement) {
        this.send('selectFeed', nextElement);
      }
    },

    selectFeed(model) {
      if(typeof model === 'string') {
        this.transitionTo(model);
      }
      else {
        this.transitionTo(model.get('constructor.modelName'), model.get('id'));
      }
    },

    editFeed(model) {
      this.transitionTo(model.get('constructor.modelName') + '.edit', model.get('id'));
    },

    addFeed() {
      this.transitionTo('feed.new');
    },

    openSettings() {
      this.transitionTo('settings');
    }
  }

});
