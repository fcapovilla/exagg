import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'li',

  open: false,

  actions: {
    toggleFavorite() {
      this.model.set('favorite', !this.model.get('favorite'));
      this.model.save();
    },

    toggleRead() {
      this.model.set('read', !this.model.get('read'));
      this.model.save();
    },

    toggleOpen() {
      this.set('open', !this.get('open'));

      if(this.get('open')) {
        this.get('onSelect')(this);
      }

      this.model.set('read', true);
      if(this.model.get('hasDirtyAttributes')) {
        this.model.save();
      }
    },
  }
});
