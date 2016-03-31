import Ember from 'ember';
import KeyboardShortcuts from 'ember-keyboard-shortcuts/mixins/route';
import AuthenticatedRouteMixin from 'ember-simple-auth/mixins/authenticated-route-mixin';

export default Ember.Route.extend(KeyboardShortcuts, AuthenticatedRouteMixin, {
  session: Ember.inject.service('session'),
  filters: Ember.inject.service('item-filters'),

  // Fetch current user data from the JWT session token and add it to the session.
  beforeModel(transition) {
    this._super(transition);

    const token = this.get('session.data.authenticated.token');
    const data = this.getTokenData(token);
    this.get('session').set('data.user', data.user);
  },

  // Extract JSON data from a JWT token.
  getTokenData(token) {
    const tokenData = atob(token.split('.')[1]);

    try {
      return JSON.parse(tokenData);
    } catch (e) {
      return tokenData;
    }
  },

  model() {
    return this.store.findAll('folder');
  },

  setupController(controller, model) {
    this._super(controller, model);
    this.get('controller').set('filters', this.get('filters'));
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
      this.controller.set('selectedElement', model);

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

    toggleReadVisibility() {
      this.get('filters').toggleReadVisibility();
    },

    openSettings() {
      this.transitionTo('settings');
    },

    logout() {
      this.get('session').invalidate();
    }
  }

});
