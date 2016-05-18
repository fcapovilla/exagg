import Ember from 'ember';
import KeyboardShortcuts from 'ember-keyboard-shortcuts/mixins/route';
import AuthenticatedRouteMixin from 'ember-simple-auth/mixins/authenticated-route-mixin';

export default Ember.Route.extend(KeyboardShortcuts, AuthenticatedRouteMixin, {
  session: Ember.inject.service('session'),
  filters: Ember.inject.service('item-filters'),
  phoenix: Ember.inject.service('phoenix'),

  folderSorting: ['position'],
  sortedFolders: Ember.computed.sort('currentModel', 'folderSorting'),

  // Fetch current user data from the JWT session token and add it to the session.
  // Also connect to phoenix channels using the JWT token.
  beforeModel(transition) {
    this._super(transition);

    const token = this.get('session.data.authenticated.token');

    const data = this.getTokenData(token);
    this.get('session').set('data.user', data.user);

    if(!this.get('phoenix.socket').isConnected()) {
      var that = this;
      this.get('phoenix').connect(data.user.id, token).on('new', function(data) {
        // Run later to prevent race conditions.
        Ember.run.later(that, function() {
          this.store.pushPayload(data);
        }, 100);
      }).on('delete', function(data) {
        var record = that.store.peekRecord(data.type, data.id);
        if(record) {
          that.store.unloadRecord(record);
        }
      });
    }
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
    'i' : 'toggleReadVisibility',
    'r' : 'refreshData',
  },

  flatList: function() {
    var flatlist = ['items', 'favorites'];
    this.get('sortedFolders').forEach(function(folder) {
      flatlist.push(folder);
      if(folder.get('open')) {
        folder.get('feeds').forEach(function(feed) {
          flatlist.push(feed);
        });
      }
    });
    return flatlist;
  }.property('sortedFolders.@each.open', 'sortedFolders.@each.feeds'),

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
    },

    refreshData() {
      this.refresh();
    },

    nextItem() {
      //TODO
    },

    previousItem() {
      //TODO
    },
  }

});
