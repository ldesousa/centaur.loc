package centaur.var;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.Arrays;

public class AssociateRaingages {

	public AssociateRaingages() {
		// TODO Auto-generated constructor stub
	}

	public static void main(String[] args) 
	{
		// TODO Auto-generated method stub
		
		String file = "/home/desouslu/git/eawag.sww.centaur/data/Subcatchments.inp";
		//BufferedReader br;
		
		//String temp = "73503            1                167631           0.2103   93.46    45.858   13.96    0                        ";
		
		try(BufferedReader br = new BufferedReader(new FileReader(file))) 
		{
		    for(String line; (line = br.readLine()) != null; ) 
		    {
				char[] vec = line.toCharArray();
				Boolean nameDone = false;
				String name = "";
				for (int i = 0; i < vec.length; i++)
				{

					if(vec[i] != ' ')
					{
						if(nameDone)
						{
							System.out.println(
								String.valueOf(Arrays.copyOfRange(vec, 0, i)) +
								"Gage_" + name +
								String.valueOf(Arrays.copyOfRange(vec, i+1, vec.length)));
							i = vec.length;
						}
						else name += vec[i];
					}
					else nameDone = true;
				}
		    }
		}
		catch (IOException e) 
		{
			e.printStackTrace();
		}
		/*finally
		{
			br.close();
		}*/

	}

}
