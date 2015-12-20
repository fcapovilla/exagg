import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'li',
  classNames: ['feed'],

  menuOpen : false,
  validFavicon: true,

  active: Ember.computed('selectedElement', function() {
    return this.get('selectedElement') === this.model;
  }),

  didInsertElement: function(){
    var that = this;
    this.$('.favicon').on('error', function(){
      return that.imageError();
    });
  },

  willDestroyElement: function(){
    this.$('.favicon').off('error');
  },

  imageError: function() {
    this.set('validFavicon', false);
  },

  actions: {
    selectFeed() {
      this.get('onSelect')(this.model);
    },

    editFeed() {
      this.get('onEdit')(this.model);
    },

    openMenu() {
      var that = this;
      that.set('menuOpen', true);

      Ember.$(document).one('mouseup', function() {
        that.set('menuOpen', false);
      });
    },

    markFeedRead() {
    },

    markFeedUnread() {
    },

    deleteFeed() {
      if(confirm('Delete feed "' + this.model.get("title") + '"?')) {
        this.model.destroyRecord();
      }
    }
  }
});
