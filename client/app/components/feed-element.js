import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'li',
  classNames: ['feed'],

  menuOpen : false,

  active: Ember.computed('selectedElement', function() {
    return this.get('selectedElement') === this.model;
  }),

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

      $(document).one('mouseup', function() {
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
