require 'ruby-graphviz'
def visualize(graph)
	created = Hash.new
	g_v = GraphViz.new( :G, :type => :digraph )
	graph.keys.each{
		|name|
	
		v_n = nil
		if(created[name] ==nil)
			created[name] = true
			v_n =g_v.add_nodes(name)
		else
			v_n = g_v.get_node(name)
		end

		graph[name].outLinks.each{
			|name_n|
			
			n_n = nil
			if(created[name_n] ==nil)
				created[name_n] = true
				n_n =g_v.add_nodes(name_n)
			else
				n_n = g_v.get_node(name_n)
			end
			g_v.add_edges(v_n,n_n)
		}
	}
	g_v.output(:jpg => "graph.jpg")
end
