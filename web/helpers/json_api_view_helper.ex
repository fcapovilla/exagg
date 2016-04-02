defmodule Exagg.JsonApiViewHelper do
  import Inflex
  import Phoenix.View

  # Add sideloaded relations for the specified models to the JSON data array in parameter.
  def sideload_relations(data, [], _), do: List.flatten(data)
  def sideload_relations(data, [model | models], sideloads) do
    data ++ Enum.map(sideloads, fn sideload ->
      case sideload do
        {submodels, view_module, file} ->
          render_many(submodels, view_module, file)
        col when is_atom(col) ->
          submodels = List.wrap(Map.get(model, col))
          {view_module, []} = Code.eval_string("Exagg." <> String.capitalize(singularize(col)) <> "View")
          render_many(submodels, view_module, singularize(col) <> ".json")
      end
    end)
    |> sideload_relations(models, sideloads)
  end
  def sideload_relations(data, model, sideloads), do: sideload_relations(data, [model], sideloads)

  # Insert relationship data in the JSON-API structure of the model in parameter.
  def insert_relationships(data, model, sideloads) do
    Enum.reduce(sideloads, data, fn sideload, acc ->
      case sideload do
        {submodels, view_module, file} -> acc
        col when is_atom(col) ->
          submodels = List.wrap(Map.get(model, col))
          relation_data = %{data: Enum.map(submodels, fn m -> %{type: Atom.to_string(col), id: m.id} end)}
          acc.relationships[col] |> update_in(&Map.merge(&1, relation_data))
      end
    end)
  end
end
