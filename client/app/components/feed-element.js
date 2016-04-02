import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'li',
  classNames: ['feed'],

  menuOpen : false,
  validFavicon: true,
  dragOver: false,

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
    },

    dragOver() {
      this.set('dragOver', true);
    },

    dragOut() {
      this.set('dragOver', false);
    },

    objectDropped(object) {
      switch(object.get('constructor.modelName')) {
        case 'folder':
          object.set('position', this.model.get('folder.position')+1);
          break;
        case 'feed':
          object.set('position', this.model.get('position')+1);
          object.set('folder', this.model.get('folder'));
          break;
      }
      object.save();
    }
  }
});
