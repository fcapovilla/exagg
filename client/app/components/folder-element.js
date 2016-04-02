import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'li',

  menuOpen: false,
  dragOver: false,

  active: Ember.computed('selectedElement', function() {
    return this.get('selectedElement') === this.model;
  }),

  actions: {
    selectFolder() {
      this.get('onSelect')(this.model);
    },

    editFolder() {
      this.get('onEdit')(this.model);
    },

    toggleOpen() {
      this.model.set('open', !this.model.get('open'));
      this.model.save();
    },

    openMenu() {
      this.set('menuOpen', true);

      var that = this;
      Ember.$(document).one('mouseup', function() {
        that.set('menuOpen', false);
      });
    },

    markFolderRead() {
    },

    markFolderUnread() {
    },

    deleteFolder() {
      if(confirm('Delete folder "' + this.model.get("title") + '"?')) {
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
          var new_position = this.model.get('position')+1;
          if(object.get('position') <= this.model.get('position')) {
            new_position--;
          }
          object.set('position', new_position);
          break;
        case 'feed':
          object.set('position', 1);
          object.set('folder', this.model);
          break;
      }
      object.save();
    }
  }
});
